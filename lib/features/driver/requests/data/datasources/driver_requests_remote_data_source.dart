import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/features/driver/requests/data/models/driver_request_model.dart';

/// مصدر البيانات البعيد لطلبات السائق
/// GET /api/driver/requests
class DriverRequestsRemoteDataSource {
  final ApiClient _apiClient;

  DriverRequestsRemoteDataSource(this._apiClient);

  /// جلب كل الطلبات
  Future<List<DriverRequestModel>> fetchRequests({String? filter}) async {
    final queryParams = filter != null ? {'filter': filter} : <String, dynamic>{};

    final response = await _apiClient.get(
      '/api/driver/requests',
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );

    final data = response.data;
    if (data == null) return [];

    List<dynamic> rawList = [];
    if (data is Map && data['data'] is List) {
      rawList = data['data'] as List;
    } else if (data is List) {
      rawList = data;
    }

    return rawList
        .whereType<Map>()
        .map((e) => DriverRequestModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// قبول الطلب
  Future<void> acceptRequest(int requestId) async {
    await _apiClient.post('/api/driver/requests/$requestId/accept', data: {});
  }

  /// رفض الطلب
  Future<void> rejectRequest(int requestId, {String? reason}) async {
    await _apiClient.post('/api/driver/requests/$requestId/reject', data: {
      if (reason != null) 'rejection_reason': reason,
    });
  }
}
