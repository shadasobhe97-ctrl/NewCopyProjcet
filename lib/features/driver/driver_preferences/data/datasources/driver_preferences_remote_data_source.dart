import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import '../models/driver_preferences_model.dart';
import '../models/zone_model.dart';

class DriverPreferencesRemoteDataSource {
  final ApiClient _apiClient;

  DriverPreferencesRemoteDataSource(this._apiClient);

  Map<String, dynamic> get _authHeader {
    final token = StorageService.getAuthorizationHeader();
    return {'Authorization': token ?? ''};
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
        return DriverPreferencesModel.fromJson(data['data'] as Map<String, dynamic>);
      }
      return null;
    } on ApiException catch (e) {
      // If server returns 404 (not found) or similar message, treat as preferences not set
      if (e.statusCode == 404 || e.message.contains('not found') || e.message.contains('لا توجد')) {
        return null;
      }
      rethrow;
    }
  }

  /// POST /api/v1/driver/preferences
  Future<bool> savePreferences({
    required int shift,
    required String subscriptionType,
    required List<int> zoneIds,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.driverPreferences,
      data: {
        'shift': shift,
        'subscription_type': subscriptionType,
        'zones': zoneIds,
      },
      headers: _authHeader,
    );
    final data = response.data;
    if (data != null) {
      final status = data['status'];
      if (status == true) {
        return true;
      }
      final serverMessage = ApiException.extractMessage(data);
      throw ApiException(serverMessage ?? 'تعذر حفظ التفضيلات.');
    }
    throw const ApiException('فشل حفظ التفضيلات بسبب استجابة خادم غير صالحة.');
  }

  /// GET /api/v1/driver/zones
  Future<List<Zone>> getZones() async {
    final response = await _apiClient.get(
      ApiEndpoints.driverZones,
      headers: _authHeader,
    );
    final data = response.data;
    if (data != null) {
      if (data is Map && data['status'] == false) {
        final serverMessage = ApiException.extractMessage(data);
        throw ApiException(serverMessage ?? 'تعذر تحميل المناطق.');
      }
      final rawList = data['data'] ?? data;
      if (rawList is List) {
        return rawList.map((e) => Zone.fromJson(e as Map<String, dynamic>)).toList();
      }
    }
    return [];
  }
}
