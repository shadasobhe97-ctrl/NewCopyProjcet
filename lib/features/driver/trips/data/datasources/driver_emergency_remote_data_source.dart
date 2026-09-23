import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../../../../core/network/api_exception.dart';
import '../../../../../core/services/storage_service.dart';
import '../models/emergency_dispatch_model.dart';

class DriverEmergencyRemoteDataSource {
  final ApiClient _apiClient;

  DriverEmergencyRemoteDataSource(this._apiClient);

  Map<String, dynamic> get _authHeader {
    final auth = StorageService.getAuthorizationHeader();
    if (auth == null || auth.isEmpty) return {};
    return {'Authorization': auth};
  }

  /// 1. جلب المهام الطارئة المتاحة للسائق البديل
  /// GET /api/driver/emergency-dispatches/available
  Future<List<EmergencyDispatchModel>> getAvailableDispatches() async {
    final response = await _apiClient.get(
      ApiEndpoints.driverEmergencyDispatchesAvailable,
      headers: _authHeader,
    );

    final data = response.data;
    if (data is Map) {
      final status = data['status']?.toString();
      if (status == 'error') {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر جلب المهام الطارئة المتاحة.');
      }
    }

    final rawList = data is Map && data['data'] is List
        ? data['data'] as List
        : (data is List ? data : []);

    return rawList
        .whereType<Map<String, dynamic>>()
        .map((e) => EmergencyDispatchModel.fromJson(e))
        .toList();
  }

  /// 2. استعراض تفاصيل المهمة الطارئة والطلاب والمسار المتبقي
  /// GET /api/driver/emergency-dispatches/{dispatchId}
  Future<EmergencyDispatchModel> getDispatchDetails(int dispatchId) async {
    final response = await _apiClient.get(
      ApiEndpoints.driverEmergencyDispatchDetails(dispatchId),
      headers: _authHeader,
    );

    final data = response.data;
    if (data is Map) {
      final status = data['status']?.toString();
      if (status == 'error') {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر جلب تفاصيل المهمة الطارئة.');
      }
      final dispatchData = data['data'] is Map
          ? Map<String, dynamic>.from(data['data'] as Map)
          : Map<String, dynamic>.from(data);

      return EmergencyDispatchModel.fromJson(dispatchData);
    }

    throw const ApiException('تعذر جلب تفاصيل المهمة الطارئة.');
  }

  /// 3. قبول المهمة الطارئة من السائق البديل
  /// POST /api/driver/emergency-dispatches/{dispatchId}/accept
  Future<Map<String, dynamic>> acceptDispatch(int dispatchId) async {
    final response = await _apiClient.post(
      ApiEndpoints.driverEmergencyDispatchAccept(dispatchId),
      headers: _authHeader,
    );

    final data = response.data;
    if (data is Map) {
      final status = data['status']?.toString();
      if (status == 'error') {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر قبول المهمة الطارئة.');
      }
      return Map<String, dynamic>.from(data);
    }

    return {'status': 'success'};
  }

  /// 4. رفض المهمة الطارئة من السائق البديل
  /// POST /api/driver/emergency-dispatches/{dispatchId}/reject
  Future<Map<String, dynamic>> rejectDispatch(int dispatchId) async {
    final response = await _apiClient.post(
      ApiEndpoints.driverEmergencyDispatchReject(dispatchId),
      headers: _authHeader,
    );

    final data = response.data;
    if (data is Map) {
      final status = data['status']?.toString();
      if (status == 'error') {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر رفض المهمة الطارئة.');
      }
      return Map<String, dynamic>.from(data);
    }

    return {'status': 'success'};
  }
}
