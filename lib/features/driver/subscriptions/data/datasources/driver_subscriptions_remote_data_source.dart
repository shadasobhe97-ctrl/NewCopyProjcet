import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import 'package:kids_transport/features/driver/subscriptions/data/models/driver_subscription_model.dart';

class DriverSubscriptionsRemoteDataSource {
  final ApiClient _apiClient;

  DriverSubscriptionsRemoteDataSource(this._apiClient);

  Map<String, dynamic> get _authHeader {
    final token = StorageService.getAuthorizationHeader();
    return {'Authorization': token ?? ''};
  }

  Future<List<DriverSubscriptionModel>> fetchAll() =>
      _fetchSubscriptions(filter: null);

  Future<List<DriverSubscriptionModel>> fetchCurrentActive() =>
      _fetchSubscriptions(filter: 'current_active');

  Future<List<DriverSubscriptionModel>> fetchPendingStart() =>
      _fetchSubscriptions(filter: 'pending_start');

  Future<List<DriverSubscriptionModel>> fetchCompleted() =>
      _fetchSubscriptions(filter: 'completed');

  Future<List<DriverSubscriptionModel>> fetchCancelled() =>
      _fetchSubscriptions(filter: 'cancelled');

  Future<List<DriverSubscriptionModel>> _fetchSubscriptions({
    String? filter,
  }) async {
    final queryParams =
        filter != null ? {'filter': filter} : <String, dynamic>{};

    final response = await _apiClient.get(
      '/api/driver/active-subscriptions',
      queryParameters: queryParams.isEmpty ? null : queryParams,
      headers: _authHeader,
    );

    final data = response.data;
    if (data == null) return [];
    if (data is Map) {
      final success = data['success'];
      if (success == false) {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر تحميل الاشتراكات.');
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
        .map((e) =>
            DriverSubscriptionModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
