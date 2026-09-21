import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../../../../core/network/api_exception.dart';
import '../../../../../core/services/storage_service.dart';
import '../../../../parent/location_change/data/models/location_change_request_model.dart';

class DriverLocationChangeRemoteDataSource {
  final ApiClient _apiClient;

  DriverLocationChangeRemoteDataSource(this._apiClient);

  Map<String, dynamic> get _authHeader {
    final auth = StorageService.getAuthorizationHeader();
    if (auth == null || auth.isEmpty) return {};
    return {'Authorization': auth};
  }

  /// 1. جلب طلبات تغيير الموقع الواردة للسائق
  /// GET /api/driver/location-change-requests (?status=pending اختياري)
  Future<List<LocationChangeRequestModel>> getRequests({String? status}) async {
    final queryParams = <String, dynamic>{};
    if (status != null && status.isNotEmpty && status != 'all') {
      queryParams['status'] = status;
    }

    final response = await _apiClient.get(
      ApiEndpoints.driverLocationChangeRequests,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
      headers: _authHeader,
    );

    final data = response.data;
    if (data is Map) {
      final success = data['success'] ?? data['status'];
      if (success == false) {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر جلب طلبات التغيير.');
      }
    }

    final rawList = data is Map && data['data'] is List
        ? data['data'] as List
        : (data is List ? data : []);

    return rawList
        .whereType<Map<String, dynamic>>()
        .map((e) => LocationChangeRequestModel.fromJson(e))
        .toList();
  }

  /// 2. موافقة أو رفض السائق لطلب تغيير الموقع (Respond)
  /// POST /api/driver/location-change-requests/{id}/respond
  /// Body: { "status": "approved" } OR { "status": "rejected", "rejection_reason": "..." }
  Future<Map<String, dynamic>> respondToRequest(
    int id, {
    required String status,
    String? rejectionReason,
  }) async {
    final body = <String, dynamic>{
      'status': status,
    };
    if (status == 'rejected' && rejectionReason != null && rejectionReason.trim().isNotEmpty) {
      body['rejection_reason'] = rejectionReason.trim();
    }

    final response = await _apiClient.post(
      ApiEndpoints.driverLocationChangeRespond(id),
      data: body,
      headers: _authHeader,
    );

    final data = response.data;
    if (data is Map) {
      final success = data['success'] ?? true;
      if (success == false) {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر تنفيذ الإجراء على الطلب.');
      }
      return Map<String, dynamic>.from(data);
    }

    return {'success': true};
  }
}
