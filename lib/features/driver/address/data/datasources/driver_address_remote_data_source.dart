import 'package:flutter/foundation.dart';
import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import 'package:kids_transport/features/driver/driver_preferences/data/models/zone_model.dart';
import 'package:kids_transport/features/parent/addresses/data/datasources/address_remote_data_source.dart';
import '../models/driver_address_model.dart';

class DriverAddressRemoteDataSource {
  final ApiClient _apiClient;

  DriverAddressRemoteDataSource(this._apiClient);

  Map<String, dynamic> _buildHeaders([String? customToken]) {
    final token = (customToken != null && customToken.isNotEmpty)
        ? customToken
        : (StorageService.getToken() ?? '');
    final authValue = token.startsWith('Bearer ') ? token : 'Bearer $token';
    return {
      if (token.isNotEmpty) 'Authorization': authValue,
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  /// جلب كافة عناوين السائق (GET /api/driver/addresses)
  Future<List<DriverAddressModel>> getAddresses({String? token}) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.driverAddresses,
        headers: _buildHeaders(token),
      );

      final dynamic resData = response.data;
      debugPrint('📥 [DriverAddress] GET /driver/addresses response: $resData');

      dynamic listData = resData;
      if (resData is Map) {
        listData = resData['data'] ?? resData['addresses'] ?? resData;
      }

      if (listData is List) {
        return listData
            .whereType<Map<String, dynamic>>()
            .map((e) => DriverAddressModel.fromJson(e))
            .toList();
      }

      return [];
    } on ApiException {
      rethrow;
    } catch (e) {
      debugPrint('❌ [DriverAddress] Error fetching addresses: $e');
      throw ApiException('فشل جلب عنوان السائق، يرجى المحاولة لاحقاً.');
    }
  }

  /// إضافة عنوان جديد لنقطة الانطلاق (POST /api/driver/addresses)
  Future<DriverAddressModel> createAddress({
    required String label,
    required double lat,
    required double lng,
    int? zoneId,
    String? token,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'label': label,
        'lat': lat,
        'lng': lng,
      };
      if (zoneId != null) {
        body['zone_id'] = zoneId;
      }

      final response = await _apiClient.post(
        ApiEndpoints.driverAddresses,
        data: body,
        headers: _buildHeaders(token),
      );

      final dynamic resData = response.data;
      debugPrint('📥 [DriverAddress] POST /driver/addresses response: $resData');

      dynamic itemData = resData;
      if (resData is Map && resData.containsKey('data')) {
        itemData = resData['data'];
      }

      if (itemData is Map<String, dynamic>) {
        return DriverAddressModel.fromJson(itemData);
      }

      throw ApiException(
        resData is Map && resData['message'] != null
            ? resData['message'].toString()
            : 'تمت العملية بدون بيانات معادة.',
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      debugPrint('❌ [DriverAddress] Error creating address: $e');
      throw ApiException('فشل حفظ نقطة انطلاق السائق، يرجى التحقق من المدخلات.');
    }
  }

  /// تعديل عنوان انطلاق السائق (PUT /api/driver/addresses/{id})
  Future<DriverAddressModel> updateAddress({
    required int addressId,
    String? label,
    double? lat,
    double? lng,
    int? zoneId,
    String? token,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (label != null && label.isNotEmpty) body['label'] = label;
      if (lat != null) body['lat'] = lat;
      if (lng != null) body['lng'] = lng;
      if (zoneId != null) body['zone_id'] = zoneId;

      final response = await _apiClient.put(
        ApiEndpoints.driverAddressById(addressId),
        data: body,
        headers: _buildHeaders(token),
      );

      final dynamic resData = response.data;
      debugPrint('📥 [DriverAddress] PUT /driver/addresses/$addressId response: $resData');

      dynamic itemData = resData;
      if (resData is Map && resData.containsKey('data')) {
        itemData = resData['data'];
      }

      if (itemData is Map<String, dynamic>) {
        return DriverAddressModel.fromJson(itemData);
      }

      throw ApiException(
        resData is Map && resData['message'] != null
            ? resData['message'].toString()
            : 'تم التحديث بنجاح.',
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      debugPrint('❌ [DriverAddress] Error updating address: $e');
      throw ApiException('فشل تحديث عنوان السائق، يرجى المحاولة لاحقاً.');
    }
  }

  /// حذف عنوان للسائق (DELETE /api/driver/addresses/{id})
  Future<bool> deleteAddress(int addressId, {String? token}) async {
    try {
      await _apiClient.delete(
        ApiEndpoints.driverAddressById(addressId),
        headers: _buildHeaders(token),
      );
      return true;
    } on ApiException {
      rethrow;
    } catch (e) {
      debugPrint('❌ [DriverAddress] Error deleting address: $e');
      throw ApiException('فشل حذف العنوان، قد يكون مستخدماً حالياً.');
    }
  }

  /// جلب قائمة المناطق (نفس الآلية المستخدمة في شاشة إضافة العنوان لولي الأمر)
  Future<List<ZoneModel>> getZones({String? token}) async {
    final parentAddressSource = AddressRemoteDataSource(_apiClient);
    return await parentAddressSource.getZones(token: token);
  }
}
