import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import 'package:kids_transport/features/driver/requests/data/models/driver_request_model.dart';

class DriverRequestsRemoteDataSource {
  final ApiClient _apiClient;

  DriverRequestsRemoteDataSource(this._apiClient);

  Map<String, dynamic> get _authHeader {
    final token = StorageService.getAuthorizationHeader();
    return {'Authorization': token ?? ''};
  }

  Future<List<DriverRequestModel>> fetchRequests({String? filter}) async {
    final queryParams = filter != null ? {'filter': filter} : <String, dynamic>{};

    final response = await _apiClient.get(
      '/api/driver/requests',
      queryParameters: queryParams.isEmpty ? null : queryParams,
      headers: _authHeader,
    );

    final data = response.data;
    if (data == null) return [];
    if (data is Map) {
      final success = data['success'];
      if (success == false) {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر تحميل الطلبات.');
      }
    }

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

  Future<void> acceptRequest(int requestId) async {
    final response = await _apiClient.post(
      '/api/driver/requests/$requestId/accept',
      data: {},
      headers: _authHeader,
    );
    final data = response.data;
    if (data is Map) {
      final success = data['success'];
      if (success == false) {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر قبول الطلب.');
      }
    }
  }

  Future<void> rejectRequest(int requestId, {String? reason}) async {
    final response = await _apiClient.post(
      '/api/driver/requests/$requestId/reject',
      data: {
        if (reason != null) 'rejection_reason': reason,
      },
      headers: _authHeader,
    );
    final data = response.data;
    if (data is Map) {
      final success = data['success'];
      if (success == false) {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر رفض الطلب.');
      }
    }
  }
}
