import 'package:flutter/foundation.dart';
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
    debugPrint('📡 [Subscriptions] Calling GET /parent/subscriptions');

    final response = await _client.get(
      ApiEndpoints.parentSubscriptions,
      headers: _authHeader,
    );
    final data = response.data;

    debugPrint('📥 [Subscriptions] Response => $data');

    if (data is Map) {
      final success = data['success'];
      if (success == false) {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر تحميل الاشتراكات.');
      }
    }

    final list = data['data'];
    if (list is List) {
      final result = list
          .map((e) => SubscriptionModel.fromJson(e as Map<String, dynamic>))
          .toList();
      debugPrint('✅ [Subscriptions] Count => ${result.length}');
      return result;
    }
    return [];
  }

  /// GET /api/guardian/requests/{id} (لشاشة التفاصيل)
  Future<SubscriptionModel> getSubscriptionDetail(int id) async {
    final response = await _client.get(
      ApiEndpoints.guardianRequestDetail(id),
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

  /// POST /api/guardian/requests/{id}/cancel (لإلغاء الطلب)
  Future<String> cancelSubscription(int id) async {
    final response = await _client.post(
      ApiEndpoints.guardianRequestCancel(id),
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
