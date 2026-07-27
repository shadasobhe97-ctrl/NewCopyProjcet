import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';
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

  Future<List<DriverSubscriptionModel>> fetchSubscriptions({
    String? filter,
  }) async {
    final queryParams = <String, dynamic>{};
    if (filter != null && filter.isNotEmpty) {
      queryParams['filter'] = filter;
    }

    final response = await _apiClient.get(
      ApiEndpoints.driverActiveSubscriptions,
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
        .map(
          (e) => DriverSubscriptionModel.fromJson(Map<String, dynamic>.from(e)),
        )
        .toList();
  }

  Future<DriverSubscriptionModel> fetchDetail(int id) async {
    final response = await _apiClient.get(
      ApiEndpoints.driverSubscriptionDetails(id),
      headers: _authHeader,
    );

    final data = response.data;
    if (data == null) throw ApiException('تعذر تحميل تفاصيل الاشتراك.');
    if (data is Map) {
      final success = data['success'];
      if (success == false) {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر تحميل تفاصيل الاشتراك.');
      }
    }

    final detail = (data is Map && data['data'] != null) ? data['data'] : data;
    return DriverSubscriptionModel.fromJson(Map<String, dynamic>.from(detail as Map));
  }
}
