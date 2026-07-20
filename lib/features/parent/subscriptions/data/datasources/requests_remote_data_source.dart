import 'package:flutter/foundation.dart';
import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import '../models/request_model.dart';

class RequestsRemoteDataSource {
  final ApiClient _client;

  RequestsRemoteDataSource(this._client);

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

  /// GET /api/parent/requests?status=...
  /// Returns (list, backendMessage)
  Future<(List<RequestModel>, String?)> getRequests({String? status}) async {
    debugPrint('Calling GET /parent/requests${status != null ? '?status=$status' : ''}');

    final queryParams = <String, dynamic>{};
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    final response = await _client.get(
      ApiEndpoints.parentRequests,
      headers: _authHeader,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    final data = response.data;

    debugPrint('GET /parent/requests response => $data');

    if (data is Map) {
      final success = data['success'];
      if (success == false) {
        final serverMessage = ApiException.extractMessage(data);
        throw ApiException(serverMessage ?? 'تعذر تحميل طلبات الاشتراك.');
      }
    }

    final backendMessage = _extractMessage(data);
    final list = data['data'];
    if (list is List) {
      final requests = list
          .map((e) => RequestModel.fromJson(e as Map<String, dynamic>))
          .toList();
      debugPrint('Requests Count => ${requests.length}');
      return (requests, backendMessage);
    }
    return (<RequestModel>[], backendMessage);
  }

  /// GET /api/parent/requests/{id}
  Future<(RequestModel, String?)> getRequestDetail(int id) async {
    debugPrint('Calling GET /parent/requests/$id');

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
    final backendMessage = _extractMessage(data);
    final detail = data['data'] ?? data;
    return (
      RequestModel.fromJson(detail as Map<String, dynamic>),
      backendMessage,
    );
  }

  /// POST /api/parent/requests/{id}/cancel
  Future<String> cancelRequest(int id, {String? reason}) async {
    debugPrint('Calling POST /parent/requests/$id/cancel');

    final response = await _client.post(
      ApiEndpoints.parentRequestCancel(id),
      data: reason != null && reason.isNotEmpty ? {'reason': reason} : null,
      headers: _authHeader,
    );
    final data = response.data;

    if (data is Map) {
      final success = data['success'];
      if (success == false) {
        final serverMessage = ApiException.extractMessage(data);
        throw ApiException(serverMessage ?? 'تعذر إلغاء الطلب.');
      }
    }
    return (data['message'] as String?) ?? 'تم إلغاء الطلب بنجاح.';
  }
}
