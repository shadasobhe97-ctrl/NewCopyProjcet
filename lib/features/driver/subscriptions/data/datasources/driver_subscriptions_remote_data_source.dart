import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/features/driver/subscriptions/data/models/driver_subscription_model.dart';

/// مصدر البيانات للاشتراكات النشطة للسائق
/// GET /api/driver/active-subscriptions
/// GET /api/driver/active-subscriptions?filter=current_active
/// GET /api/driver/active-subscriptions?filter=pending_start
/// GET /api/driver/active-subscriptions?filter=completed
/// GET /api/driver/active-subscriptions?filter=cancelled
class DriverSubscriptionsRemoteDataSource {
  final ApiClient _apiClient;

  DriverSubscriptionsRemoteDataSource(this._apiClient);

  /// جلب كل الاشتراكات (بدون فلتر)
  Future<List<DriverSubscriptionModel>> fetchAll() =>
      _fetchSubscriptions(filter: null);

  /// الاشتراكات النشطة حالياً
  Future<List<DriverSubscriptionModel>> fetchCurrentActive() =>
      _fetchSubscriptions(filter: 'current_active');

  /// الاشتراكات التي تنتظر البدء
  Future<List<DriverSubscriptionModel>> fetchPendingStart() =>
      _fetchSubscriptions(filter: 'pending_start');

  /// الاشتراكات المكتملة
  Future<List<DriverSubscriptionModel>> fetchCompleted() =>
      _fetchSubscriptions(filter: 'completed');

  /// الاشتراكات الملغية
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
        .map((e) =>
            DriverSubscriptionModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
