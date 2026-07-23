import 'package:flutter/foundation.dart';
import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import '../models/active_subscription_model.dart';

class SubscriptionsRemoteDataSource {
  final ApiClient _client;

  SubscriptionsRemoteDataSource(this._client);

  Map<String, dynamic> get _authHeader {
    final token = StorageService.getAuthorizationHeader();
    return {'Authorization': token ?? ''};
  }

  String? _extractMessage(dynamic data) {
    if (data is Map && data['message'] != null) {
      final msg = data['message'].toString();
      return msg.isNotEmpty ? msg : null;
    }
    return null;
  }

  /// GET /api/parent/active-subscriptions?filter=...
  Future<(List<ActiveSubscriptionModel>, String?)> getActiveSubscriptions({
    String? filter,
  }) async {
    debugPrint('📡 [ActiveSubscriptions] Calling GET /parent/active-subscriptions${filter != null ? '?filter=$filter' : ''}');

    final queryParams = <String, dynamic>{};
    if (filter != null && filter.isNotEmpty) {
      queryParams['filter'] = filter;
    }

    final response = await _client.get(
      ApiEndpoints.parentActiveSubscriptions,
      headers: _authHeader,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    final data = response.data;

    debugPrint('📥 [ActiveSubscriptions] Response => $data');

    if (data is Map) {
      final success = data['success'];
      if (success == false) {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر تحميل الاشتراكات.');
      }
    }

    final backendMessage = _extractMessage(data);
    final list = data['data'];
    if (list is List) {
      final result = list
          .map((e) =>
              ActiveSubscriptionModel.fromJson(e as Map<String, dynamic>))
          .toList();
      debugPrint('✅ [ActiveSubscriptions] Count => ${result.length}');
      return (result, backendMessage);
    }
    return (<ActiveSubscriptionModel>[], backendMessage);
  }

  /// GET /api/guardian/requests/{id} (لشاشة التفاصيل)
  Future<ActiveSubscriptionModel> getSubscriptionDetail(int id) async {
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
    return ActiveSubscriptionModel.fromJson(detail as Map<String, dynamic>);
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
