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
      if (success == false || success?.toString() == 'false') {
        final serverMessage = ApiException.extractMessage(data);
        throw ApiException(serverMessage ?? 'تعذر البحث عن السائقين.');
      }
      final rawList = data['data'] ?? data['drivers'];
      final list = rawList is List ? rawList : [];
      return list.map((e) => DriverSearchModel.fromJson(e as Map<String, dynamic>)).toList();
    } else if (data is List) {
      return data.map((e) => DriverSearchModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw const ApiException('استجابة الخادم غير مقروءة.');
  }

  /// POST /api/parent
  Future<String> sendSubscription(SubscriptionRequest request) async {
    final response = await _client.post(
      ApiEndpoints.parentSubscriptions,
      data: request.toJson(),
      headers: _authHeader,
    );
    final data = response.data;
    if (data is Map) {
      final success = data['success'] ?? data['status'];
      final message = data['message']?.toString() ?? 'تم إرسال طلب الاشتراك بنجاح.';
      if (success == false || success?.toString() == 'false') {
        throw ApiException(message);
      }
      return message;
    }
    return 'تم إرسال طلب الاشتراك بنجاح.';
  }
}
