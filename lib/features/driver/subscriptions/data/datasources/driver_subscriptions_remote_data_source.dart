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
      // الباك إند يستخدم success أحياناً و status أحياناً أخرى
      final ok = data['success'] ?? data['status'];
      if (ok == false) {
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
      final ok = data['success'] ?? data['status'];
      if (ok == false) {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر تحميل تفاصيل الاشتراك.');
      }
    }

    final detail = (data is Map && data['data'] != null) ? data['data'] : data;
    return DriverSubscriptionModel.fromJson(Map<String, dynamic>.from(detail as Map));
  }

  /// POST /api/driver/active-subscriptions/{id}/cancel (لإلغاء الاشتراك المفعل)
  Future<String> cancelSubscription(int id) async {
    final response = await _apiClient.post(
      ApiEndpoints.driverActiveSubscriptionCancel(id),
      data: {
        'active_subscription_id': id,
      },
      headers: _authHeader,
    );

    final data = response.data;
    if (data is Map) {
      final ok = data['success'] ?? data['status'];
      if (ok == false) {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر إلغاء الاشتراك.');
      }
      return (data['message'] as String?) ?? 'تم إلغاء الاشتراك بنجاح.';
    }
    return 'تم إلغاء الاشتراك بنجاح.';
  }
}
