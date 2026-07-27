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
    debugPrint('');
    debugPrint('╔══════════════════════════════════════════════════╗');
    debugPrint('║  SearchRemoteDataSource.sendSubscription        ║');
    debugPrint('╚══════════════════════════════════════════════════╝');

    final fullUrl =
        '${ApiEndpoints.baseUrl}${ApiEndpoints.parentrequestSubscription}';
    debugPrint('📍  الرابط الكامل: POST $fullUrl');

    final authHeader = _authHeader;
    final tokenValue = authHeader['Authorization'];
    debugPrint(
      '🔑  التوكن: ${tokenValue != null && tokenValue.isNotEmpty ? tokenValue : "⚠️  بدون توكن"}',
    );
    if (tokenValue == null || tokenValue.isEmpty) {
      debugPrint('⚠️  تحذير: التوكن فارغ أو غير موجود!');
    }

    final jsonBody = request.toJson();
    debugPrint('📦  البيانات (JSON):');
    debugPrint('  ${jsonBody.toString()}');
    debugPrint('');
    debugPrint('════════════════════════════════════════════════════');
    debugPrint('');

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
    debugPrint(
      '<<< [DataSource] Response data is not a Map, returning default message',
    );
    return 'تم إرسال طلب الاشتراك بنجاح.';
  }
}
