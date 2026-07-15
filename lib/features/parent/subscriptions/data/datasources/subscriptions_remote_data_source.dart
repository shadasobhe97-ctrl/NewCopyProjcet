import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import '../models/subscription_model.dart';

class SubscriptionsRemoteDataSource {
  final ApiClient _client;

  SubscriptionsRemoteDataSource(this._client);

  Map<String, dynamic> get _authHeader {
    final token = StorageService.getAuthorizationHeader();
    return {'Authorization': token ?? ''};
  }

  /// GET /api/parent/subscriptions
  Future<List<SubscriptionModel>> getSubscriptions() async {
    final response = await _client.get(
      ApiEndpoints.parentRequests,
      headers: _authHeader,
    );
    final data = response.data;
    if (data is Map) {
      final success = data['success'];
      if (success == false) {
        final serverMessage = ApiException.extractMessage(data);
        throw ApiException(serverMessage ?? 'تعذر تحميل طلبات الاشتراك.');
      }
    }
    final list = data['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => SubscriptionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/parent/requests/{id}
  Future<SubscriptionModel> getSubscriptionDetail(int id) async {
    final response = await _client.get(
      ApiEndpoints.parentRequestDetail(id),
      headers: _authHeader,
    );
    final data = response.data;
    if (data is Map) {
      final success = data['success'];
      if (success == false) {
        final serverMessage = ApiException.extractMessage(data);
        throw ApiException(serverMessage ?? 'تعذر تحميل تفاصيل الطلب.');
      }
    }
    final detail = data['data'] ?? data;
    return SubscriptionModel.fromJson(detail as Map<String, dynamic>);
  }

  /// DELETE /api/parent/subscriptions/{id}
  Future<String> cancelSubscription(int id) async {
    final response = await _client.delete(
      ApiEndpoints.parentRequestDelete(id),
      headers: _authHeader,
    );
    final data = response.data;
    if (data is Map) {
      final success = data['success'];
      if (success == false) {
        final serverMessage = ApiException.extractMessage(data);
        throw ApiException(serverMessage ?? 'تعذر إلغاء طلب الاشتراك.');
      }
    }
    return (data['message'] as String?) ?? 'تم إلغاء طلب الاشتراك بنجاح.';
  }
}
