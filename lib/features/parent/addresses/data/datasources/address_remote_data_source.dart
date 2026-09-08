import 'package:flutter/foundation.dart';
import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import 'package:kids_transport/features/driver/driver_preferences/data/models/zone_model.dart';
import 'package:kids_transport/features/parent/addresses/data/models/address_model.dart';

class AddressRemoteDataSource {
  final ApiClient _client;

  AddressRemoteDataSource(this._client);

  /// لا نرسل Header فارغ لو ما فيه توكن (بعض السيرفرات تتعامل مع
  /// Authorization: '' بشكل مختلف عن غياب الهيدر تماماً، فيفضّل حذفه).
  Map<String, dynamic> get _authHeader {
    final token = StorageService.getAuthorizationHeader();
    if (token == null || token.isEmpty) return {};
    return {'Authorization': token};
  }

  /// يحاول استخراج قائمة العناصر بغض النظر عن شكل استجابة السيرفر
  /// (data:[...] أو addresses:[...] أو Pagination بصيغة data:{data:[...]})
  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      final candidate = data['data'] ?? data['addresses'] ?? data['result'];
      if (candidate is List) return candidate;
      if (candidate is Map && candidate['data'] is List) {
        return candidate['data'] as List;
      }
    }
    return const [];
  }

  /// استخراج المناطق من مختلف هياكل البيانات المحتملة
  /// يدعم: { data: [{id, zone_name, ...}] } و { data: [{zones:[...]}] } وغيرها
  List<ZoneModel> _extractZones(dynamic responseData) {
    final List<ZoneModel> result = [];
    final Set<int> seenIds = {};

    void addZone(dynamic z) {
      if (z is! Map) return;
      try {
        final zone = ZoneModel.fromJson(Map<String, dynamic>.from(z));
        if (zone.id > 0 && !seenIds.contains(zone.id)) {
          seenIds.add(zone.id);
          result.add(zone);
        }
      } catch (_) {}
    }

    // استخرج قائمة الـ data الرئيسية من الرد
    dynamic data = responseData;
    if (responseData is Map) {
      data = responseData['data'] ?? responseData['zones'] ?? responseData;
    }

    // الحالة المباشرة: data هي قائمة مناطق (ردّ /admin/zones الجديد)
    if (data is List) {
      for (final item in data) {
        if (item is Map) {
          // كل عنصر قد يكون منطقة مباشرة أو يحتوي على قائمة zones
          if (item.containsKey('zones') && item['zones'] is List) {
            for (final z in item['zones'] as List) {
              addZone(z);
            }
          } else if (item.containsKey('id') &&
              (item.containsKey('name') || item.containsKey('zone_name'))) {
            addZone(item);
          } else if (item.containsKey('sub_municipalities')) {
            // هيكل municipality → sub_municipalities → zones
            final subs = item['sub_municipalities'];
            if (subs is List) {
              for (final sub in subs) {
                if (sub is Map && sub['zones'] is List) {
                  for (final z in sub['zones'] as List) {
                    addZone(z);
                  }
                }
              }
            }
          }
        }
      }
      if (result.isNotEmpty) return result;
    }

    // الحالة المتداخلة: نبحث بشكل عودي
    void traverse(dynamic node) {
      if (node == null) return;
      if (node is List) {
        for (final item in node) {
          traverse(item);
        }
      } else if (node is Map) {
        if (node['zones'] is List) {
          for (final z in node['zones'] as List) {
            addZone(z);
          }
        }
        if (node.containsKey('id') &&
            (node.containsKey('name') || node.containsKey('zone_name')) &&
            !node.containsKey('sub_municipalities') &&
            !node.containsKey('zones')) {
          addZone(node);
        }
        if (node['sub_municipalities'] is List) {
          traverse(node['sub_municipalities']);
        }
        if (node['geography_tree'] != null) {
          traverse(node['geography_tree']);
        }
        if (node['zones_tree'] != null) {
          traverse(node['zones_tree']);
        }
        if (node['data'] != null) {
          traverse(node['data']);
        }
      }
    }

    traverse(responseData);
    return result;
  }

  /// يتحقق من نجاح الطلب. بعض الردود (401 / 422 / رسائل بدون success)
  /// لا تحتوي success:false صراحة، فنطبع تحذيراً بدل تجاهلها بصمت.
  void _checkSuccess(dynamic data, String fallbackMessage) {
    if (data is Map) {
      final success = data['success'] ?? data['status'];
      if (success == false) {
        final serverMessage = ApiException.extractMessage(data);
        throw ApiException(serverMessage ?? fallbackMessage);
      }
      if (success == null && data['data'] == null && data['message'] != null) {
        debugPrint(
          '⚠️ [Addresses API] رد غير متوقع من السيرفر (لا success ولا data): ${data['message']}',
        );
      }
    }
  }

  Map<String, dynamic> _buildAuthHeader([String? customToken]) {
    if (customToken != null && customToken.isNotEmpty) {
      final token = customToken.startsWith('Bearer ') ? customToken : 'Bearer $customToken';
      return {'Authorization': token};
    }
    final token = StorageService.getAuthorizationHeader();
    if (token == null || token.isEmpty) return {};
    return {'Authorization': token};
  }

  /// GET /api/parent/zones لجلب كافة المناطق المتاحة لأولياء الأمور
  Future<List<ZoneModel>> getZones({String? token}) async {
    final headers = _buildAuthHeader(token);
    debugPrint('🔑 [Addresses API] GET /parent/zones sending Auth Header: ${headers['Authorization'] != null ? 'Bearer ***' : 'EMPTY'}');
    try {
      final response = await _client.get(
        ApiEndpoints.parentZones,
        headers: headers,
      );
      final data = response.data;
      debugPrint('📥 [Addresses API] FULL BACKEND RESPONSE FOR /parent/zones:\n$data');
      final zones = _extractZones(data);
      debugPrint('📍 [Addresses API] تم استخراج ${zones.length} منطقة بنجاح.');
      return zones;
    } catch (e) {
      debugPrint('⚠️ [Addresses API] خطأ أثناء استدعاء GET /parent/zones: $e');
      return const [];
    }
  }

  /// GET /api/parent/addresses
  Future<List<AddressModel>> getAddresses() async {
    final response = await _client.get(
      ApiEndpoints.parentAddresses,
      headers: _authHeader,
    );
    final data = response.data;
    debugPrint('📥 [Addresses API] GET /addresses => $data');

    _checkSuccess(data, 'تعذر تحميل العناوين المحفوظة.');

    final list = _extractList(data);
    if (list.isEmpty) {
      debugPrint(
        '📭 [Addresses API] القائمة فارغة أو لم يتم إيجاد مفتاح البيانات المتوقع في الرد.',
      );
    }
    return list
        .map((e) => AddressModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// POST /api/parent/addresses
  Future<String> addAddress(AddressModel address) async {
    final payload = address.toJson();

    final response = await _client.post(
      ApiEndpoints.parentAddresses,
      data: payload,
      headers: _authHeader,
    );
    final data = response.data;
    debugPrint('📤 [Addresses API] POST /addresses => $data');
    _checkSuccess(data, 'تعذر إضافة العنوان.');
    return (data is Map ? data['message'] as String? : null) ??
        'تم إضافة العنوان بنجاح';
  }

  /// PUT /api/parent/addresses/{id}
  Future<String> updateAddress(AddressModel address) async {
    final response = await _client.put(
      ApiEndpoints.parentAddressById(address.id!),
      data: address.toJson(),
      headers: _authHeader,
    );
    final data = response.data;
    debugPrint('📤 [Addresses API] PUT /addresses/${address.id} => $data');
    _checkSuccess(data, 'تعذر تحديث العنوان.');
    return (data is Map ? data['message'] as String? : null) ??
        'تم تحديث العنوان بنجاح';
  }

  /// DELETE /api/parent/addresses/{id}
  Future<String> deleteAddress(String id) async {
    final response = await _client.delete(
      ApiEndpoints.parentAddressById(id),
      headers: _authHeader,
    );
    final data = response.data;
    debugPrint('🗑️ [Addresses API] DELETE /addresses/$id => $data');
    _checkSuccess(data, 'تعذر حذف العنوان.');
    return (data is Map ? data['message'] as String? : null) ??
        'تم حذف العنوان بنجاح';
  }
}
