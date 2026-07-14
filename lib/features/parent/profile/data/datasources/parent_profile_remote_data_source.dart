import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import '../models/parent_model.dart';

class ParentProfileRemoteDataSource {
  final ApiClient _client;

  ParentProfileRemoteDataSource(this._client);

  Map<String, dynamic> get _authHeader {
    final token = StorageService.getAuthorizationHeader();
    return {'Authorization': token ?? ''};
  }

  /// GET /api/parent/profile
  Future<ParentModel> getParentProfile() async {
    try {
      final response = await _client.get(
        ApiEndpoints.parentProfile,
        headers: _authHeader,
      );
      final data = response.data;
      if (data is Map) {
        final success = data['success'];
        if (success == false) {
          final serverMessage = ApiException.extractMessage(data);
          throw ApiException(serverMessage ?? 'تعذر تحميل ملف ولي الأمر.');
        }
      }
      return ParentModel.fromJson(data['data']);
    } catch (e) {
      rethrow;
    }
  }

  /// POST /api/parent/profile/update
  Future<ParentModel> updateParentProfile({
    required String fullName,
    required String phoneNumber,
    String? email,
    String? alternativePhone,
  }) async {
    try {
      final response = await _client.post(
        ApiEndpoints.parentProfileUpdate,
        headers: _authHeader,
        data: {
          'full_name': fullName,
          'phone_number': phoneNumber,
          if (email != null) 'email': email,
          if (alternativePhone != null) 'alternative_phone': alternativePhone,
        },
      );
      final data = response.data;
      if (data is Map) {
        final success = data['success'];
        if (success == false) {
          final serverMessage = ApiException.extractMessage(data);
          throw ApiException(serverMessage ?? 'تعذر تحديث الملف الشخصي.');
        }
      }
      return ParentModel.fromJson(data['data']);
    } catch (e) {
      rethrow;
    }
  }
}
