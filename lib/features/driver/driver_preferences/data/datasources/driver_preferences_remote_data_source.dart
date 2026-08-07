import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import '../models/driver_preferences_model.dart';
import '../models/preference_defaults_model.dart';

class DriverPreferencesRemoteDataSource {
  final ApiClient _apiClient;

  DriverPreferencesRemoteDataSource(this._apiClient);

  Map<String, dynamic> get _authHeader {
    final token = StorageService.getAuthorizationHeader();
    return {'Authorization': token ?? ''};
  }

  /// GET /api/v1/driver/preferences/defaults
  Future<PreferenceDefaultsModel> getPreferenceDefaults() async {
    final response = await _apiClient.get(
      ApiEndpoints.driverPreferenceDefaults,
      headers: _authHeader,
    );
    final data = response.data;
    if (data != null && data['status'] == true && data['data'] != null) {
      return PreferenceDefaultsModel.fromJson(
        data['data'] as Map<String, dynamic>,
      );
    }
    final serverMessage = ApiException.extractMessage(data);
    throw ApiException(
      serverMessage ?? 'تعذر تحميل الخيارات الافتراضية للتفضيلات.',
    );
  }

  /// GET /api/v1/driver/preferences
  Future<DriverPreferencesModel?> getPreferences() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.driverPreferences,
        headers: _authHeader,
      );
      final data = response.data;
      if (data != null && data['status'] == true && data['data'] != null) {
        return DriverPreferencesModel.fromJson(
          data['data'] as Map<String, dynamic>,
        );
      }
      return null;
    } on ApiException catch (e) {
      if (e.statusCode == 404 ||
          e.message.contains('not found') ||
          e.message.contains('لا توجد')) {
        return null;
      }
      rethrow;
    }
  }

  /// PUT /api/v1/driver/preferences
  Future<bool> updatePreferences(Map<String, dynamic> payload) async {
    final response = await _apiClient.post(
      ApiEndpoints.driverPreferences,
      data: payload,
      headers: _authHeader,
    );
    final data = response.data;
    if (data != null) {
      final status = data['status'];
      if (status == true) {
        return true;
      }
      final serverMessage = ApiException.extractMessage(data);
      throw ApiException(serverMessage ?? 'تعذر تحديث التفضيلات.');
    }
    throw const ApiException(
      'فشل تحديث التفضيلات بسبب استجابة خادم غير صالحة.',
    );
  }
}
