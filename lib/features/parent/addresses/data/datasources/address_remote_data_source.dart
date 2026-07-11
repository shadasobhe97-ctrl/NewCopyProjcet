import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import 'package:kids_transport/features/parent/addresses/data/models/address_model.dart';

class AddressRemoteDataSource {
  final ApiClient _client;

  AddressRemoteDataSource(this._client);

  Map<String, dynamic> get _authHeader {
    final token = StorageService.getAuthorizationHeader();
    return {'Authorization': token ?? ''};
  }

  /// GET /api/parent/addresses
  Future<List<AddressModel>> getAddresses() async {
    final response = await _client.get(
      ApiEndpoints.parentAddresses,
      headers: _authHeader,
    );
    final data = response.data;
    if (data is Map) {
      final success = data['success'];
      if (success == false) {
        final serverMessage = ApiException.extractMessage(data);
        throw ApiException(serverMessage ?? 'تعذر تحميل العناوين المحفوظة.');
      }
    }
    final list = data['data'] as List<dynamic>? ?? [];
    return list.map((e) => AddressModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// POST /api/parent/addresses
  Future<String> addAddress(AddressModel address) async {
    final response = await _client.post(
      ApiEndpoints.parentAddresses,
      data: address.toJson(),
      headers: _authHeader,
    );
    final data = response.data;
    if (data is Map) {
      final success = data['success'];
      if (success == false) {
        final serverMessage = ApiException.extractMessage(data);
        throw ApiException(serverMessage ?? 'تعذر إضافة العنوان.');
      }
    }
    return (data['message'] as String?) ?? 'تم إضافة العنوان بنجاح';
  }

  /// POST /api/parent/addresses/{id}
  Future<String> updateAddress(AddressModel address) async {
    final response = await _client.post(
      ApiEndpoints.parentAddressById(address.id!),
      data: address.toJson(),
      headers: _authHeader,
    );
    final data = response.data;
    if (data is Map) {
      final success = data['success'];
      if (success == false) {
        final serverMessage = ApiException.extractMessage(data);
        throw ApiException(serverMessage ?? 'تعذر تحديث العنوان.');
      }
    }
    return (data['message'] as String?) ?? 'تم تحديث العنوان بنجاح';
  }

  /// DELETE /api/parent/addresses/{id}
  Future<String> deleteAddress(String id) async {
    final response = await _client.delete(
      ApiEndpoints.parentAddressById(id),
      headers: _authHeader,
    );
    final data = response.data;
    if (data is Map) {
      final success = data['success'];
      if (success == false) {
        final serverMessage = ApiException.extractMessage(data);
        throw ApiException(serverMessage ?? 'تعذر حذف العنوان.');
      }
    }
    return (data['message'] as String?) ?? 'تم حذف العنوان بنجاح';
  }
}
