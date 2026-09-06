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
  List<ZoneModel> _extractZones(dynamic data) {
    final List<ZoneModel> result = [];
    final Set<int> seenIds = {};

    void addZone(dynamic z) {
      if (z is Map) {
        final zone = ZoneModel.fromJson(Map<String, dynamic>.from(z));
        if (zone.id > 0 && !seenIds.contains(zone.id)) {
          seenIds.add(zone.id);
          result.add(zone);
        }
      }
    }

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
            node.containsKey('name') &&
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

    traverse(data);
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

  /// GET /api/admin/zones-tree أو defaults لجلب قائمة المناطق
  Future<List<ZoneModel>> getZones() async {
    try {
      final response = await _client.get(
        ApiEndpoints.adminZonesTree,
        headers: _authHeader,
      );
      final data = response.data;
      debugPrint('📥 [Addresses API] GET /admin/zones-tree => $data');
      final zones = _extractZones(data);
      if (zones.isNotEmpty) return zones;
    } catch (e) {
      debugPrint(
        '⚠️ [Addresses API] فشل جلب admin/zones-tree: $e, المحاولة من defaults...',
      );
    }

    try {
      final response = await _client.get(
        ApiEndpoints.driverPreferenceDefaults,
        headers: _authHeader,
      );
      final data = response.data;
      final zones = _extractZones(data);
      if (zones.isNotEmpty) return zones;
    } catch (e) {
      debugPrint('⚠️ [Addresses API] فشل جلب driverPreferenceDefaults: $e');
    }

    return const [];
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

  /// POST /api/parent/addresses/{id}
  Future<String> updateAddress(AddressModel address) async {
    final response = await _client.post(
      ApiEndpoints.parentAddressById(address.id!),
      data: address.toJson(),
      headers: _authHeader,
    );
    final data = response.data;
    debugPrint('📤 [Addresses API] POST /addresses/${address.id} => $data');
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
