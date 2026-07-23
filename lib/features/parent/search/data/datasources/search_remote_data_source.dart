import 'package:flutter/foundation.dart';
import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import '../models/driver_search_model.dart';
import '../models/subscription_request.dart';

class SearchRemoteDataSource {
  final ApiClient _client;

  SearchRemoteDataSource(this._client);

  Map<String, dynamic> get _authHeader {
    final token = StorageService.getAuthorizationHeader();
    return {'Authorization': token ?? ''};
  }

  /// POST /api/parent/drivers/search
  Future<List<DriverSearchModel>> searchDrivers(
    Map<String, dynamic> queryParameters,
  ) async {
    final response = await _client.post(
      ApiEndpoints.parentDriversSearch,
      data: queryParameters,
      headers: _authHeader,
    );
    final data = response.data;
    if (data is Map) {
      final success = data['success'] ?? data['status'];
      if (success == false) {
        final serverMessage = ApiException.extractMessage(data);
        throw ApiException(serverMessage ?? 'تعذر البحث عن السائقين.');
      }
      final list =
          data['data'] as List<dynamic>? ??
          data['drivers'] as List<dynamic>? ??
          [];
      return list
          .map((e) => DriverSearchModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (data is List) {
      return data
          .map((e) => DriverSearchModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw const ApiException('استجابة الخادم غير مقروءة.');
  }

  /// POST /api/parent/requests
  Future<String> sendSubscription(SubscriptionRequest request) async {
    debugPrint('\n================= SEARCH REMOTE DATA SOURCE =================');
    debugPrint('>>> Endpoint: POST ${ApiEndpoints.parentrequestSubscription}');
    debugPrint('>>> Full URL: ${ApiEndpoints.baseUrl}${ApiEndpoints.parentrequestSubscription}');
    debugPrint('>>> HTTP Method: POST');

    final authHeader = _authHeader;
    debugPrint('>>> Headers:');
    debugPrint('  Authorization: ${authHeader['Authorization']}');
    debugPrint('  Content-Type: application/json');
    debugPrint('  Accept: application/json');

    final jsonBody = request.toJson();
    debugPrint('>>> Request Body: $jsonBody');
    debugPrint('============================================================\n');
    debugPrint('\n>>> [ApiClient.post] will now print the request...');

    final response = await _client.post(
      ApiEndpoints.parentrequestSubscription,
      data: jsonBody,
      headers: authHeader,
    );
    final data = response.data;
    debugPrint('\n<<< [DataSource] Raw response data: $data');
    if (data is Map) {
      final success = data['success'] ?? data['status'];
      final message =
          data['message']?.toString() ?? 'تم إرسال طلب الاشتراك بنجاح.';
      debugPrint('<<< [DataSource] success: $success, message: $message');
      if (success == false) {
        debugPrint('<<< [DataSource] Throwing ApiException with: $message');
        throw ApiException(message);
      }
      debugPrint('<<< [DataSource] Returning success message: $message');
      return message;
    }
    debugPrint('<<< [DataSource] Response data is not a Map, returning default message');
    return 'تم إرسال طلب الاشتراك بنجاح.';
  }
}
