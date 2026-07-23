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

  Future<PaginatedDriverRequests> fetchRequests({String? filter, int page = 1}) async {
    final queryParams = <String, dynamic>{'page': page};
    if (filter != null) {
      queryParams['filter'] = filter;
    }

    final response = await _apiClient.get(
      '/api/driver/requests',
      queryParameters: queryParams.isEmpty ? null : queryParams,
      headers: _authHeader,
    );

    final data = response.data;
    if (data == null) return PaginatedDriverRequests(data: [], currentPage: 1, lastPage: 1, perPage: 15);
    if (data is Map) {
      final success = data['success'];
      if (success == false) {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر تحميل الطلبات.');
      }
    }

    List<dynamic> rawList = [];
    int currentPage = 1;
    int lastPage = 1;
    int perPage = 15;
    String? nextPageUrl;

    if (data is Map) {
      if (data['data'] is List) {
        rawList = data['data'] as List;
        currentPage = data['current_page'] is int ? data['current_page'] : 1;
        lastPage = data['last_page'] is int ? data['last_page'] : 1;
        perPage = data['per_page'] is int ? data['per_page'] : 15;
        nextPageUrl = data['next_page_url']?.toString();
      } else {
        // Fallback if pagination is not directly at root but under another key, or not paginated
        rawList = data['data'] ?? [];
      }
    } else if (data is List) {
      rawList = data;
    }

    final requests = rawList
        .whereType<Map>()
        .map((e) => DriverRequestModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return PaginatedDriverRequests(
      data: requests,
      currentPage: currentPage,
      lastPage: lastPage,
      perPage: perPage,
      nextPageUrl: nextPageUrl,
    );
  }

  Future<DriverRequestModel> fetchRequestDetails(int requestId) async {
    final response = await _apiClient.get(
      '/api/driver/requests/$requestId',
      headers: _authHeader,
    );

    final data = response.data;
    if (data is Map) {
      final success = data['success'];
      if (success == false) {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر تحميل تفاصيل الطلب.');
      }
      Map<String, dynamic> requestData;
      if (data['data'] is Map) {
        requestData = Map<String, dynamic>.from(data['data'] as Map);
      } else {
        requestData = Map<String, dynamic>.from(data);
      }
      return DriverRequestModel.fromJson(requestData);
    }
    throw ApiException('تعذر تحميل تفاصيل الطلب.');
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

  Future<void> rejectRequest(int requestId, {required String reason}) async {
    final response = await _apiClient.post(
      '/api/driver/requests/$requestId/reject',
      data: {
        'rejection_reason': reason,
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
