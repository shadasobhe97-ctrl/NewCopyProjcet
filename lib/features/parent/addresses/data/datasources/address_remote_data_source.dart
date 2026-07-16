import 'package:flutter/foundation.dart';
import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/core/services/storage_service.dart';
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
    final response = await _client.post(
      ApiEndpoints.parentAddresses,
      data: address.toJson(),
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
