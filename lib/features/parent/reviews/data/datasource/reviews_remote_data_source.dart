import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import 'package:kids_transport/features/parent/reviews/data/models/review_model.dart';
import 'package:kids_transport/features/parent/reviews/data/models/subscription_check_model.dart';

class ReviewsRemoteDataSource {
  final ApiClient _client;

  ReviewsRemoteDataSource(this._client);

  Map<String, dynamic> get _authHeader {
    final token = StorageService.getAuthorizationHeader();
    return {'Authorization': token ?? ''};
  }

  Future<SubscriptionCheckModel> checkSubscription(int driverId) async {
    final endpoint = ApiEndpoints.checkSubscription(driverId);
    debugPrint('\n================ [API REVIEWS] checkSubscription ================');
    debugPrint('📌 GET Endpoint: $endpoint');
    debugPrint('🔑 Token: ${_authHeader['Authorization']}');
    try {
      final response = await _client.get(
        endpoint,
        headers: _authHeader,
      );
      debugPrint('✅ Check Subscription Status: ${response.statusCode}');
      debugPrint('📄 Response Body: ${response.data}');
      debugPrint('=================================================================\n');
      return SubscriptionCheckModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      debugPrint('❌ [API REVIEWS ERROR] checkSubscription Failed!');
      debugPrint('🔴 Error: $e');
      if (e is DioException) {
        debugPrint('   Status Code: ${e.response?.statusCode}');
        debugPrint('   Response Data: ${e.response?.data}');
      }
      debugPrint('=================================================================\n');
      rethrow;
    }
  }

  Future<ReviewsResponse> getReviews(int driverId, int page) async {
    final endpoint = '${ApiEndpoints.getDriverReviews(driverId)}?page=$page';
    debugPrint('\n================ [API REVIEWS] getReviews ================');
    debugPrint('📌 GET Endpoint: $endpoint');
    try {
      final response = await _client.get(
        endpoint,
        headers: _authHeader,
      );
      debugPrint('✅ Get Reviews Status: ${response.statusCode}');
      debugPrint('📄 Response Body: ${response.data}');
      debugPrint('===========================================================\n');
      return ReviewsResponse.fromJson(response.data);
    } catch (e) {
      debugPrint('❌ [API REVIEWS ERROR] getReviews Failed!');
      debugPrint('🔴 Error: $e');
      if (e is DioException) {
        debugPrint('   Status Code: ${e.response?.statusCode}');
        debugPrint('   Response Data: ${e.response?.data}');
      }
      debugPrint('===========================================================\n');
      rethrow;
    }
  }

  Future<void> postReview({
    required int driverId,
    required int rating,
    required String comment,
  }) async {
    final endpoint = ApiEndpoints.driverReviews;
    final body = {'driver_id': driverId, 'rating': rating, 'comment': comment};
    debugPrint('\n================ [API REVIEWS] postReview ================');
    debugPrint('📌 POST Endpoint: $endpoint');
    debugPrint('📤 Body: $body');
    debugPrint('🔑 Token: ${_authHeader['Authorization']}');
    try {
      final response = await _client.post(
        endpoint,
        data: body,
        headers: _authHeader,
      );
      debugPrint('✅ Post Review Status: ${response.statusCode}');
      debugPrint('📄 Response Body: ${response.data}');
      debugPrint('===========================================================\n');
    } catch (e) {
      debugPrint('❌ [API REVIEWS ERROR] postReview Failed!');
      debugPrint('🔴 Exception: $e');
      if (e is DioException) {
        debugPrint('   Status Code: ${e.response?.statusCode}');
        debugPrint('   Response Headers: ${e.response?.headers}');
        debugPrint('   Response Data: ${e.response?.data}');
        debugPrint('   Message: ${e.message}');
      }
      debugPrint('===========================================================\n');
      rethrow;
    }
  }

  Future<void> updateReview({
    required int reviewId,
    required int rating,
    required String comment,
  }) async {
    final endpoint = ApiEndpoints.driverReviewById(reviewId);
    final body = {'rating': rating, 'comment': comment};
    debugPrint('\n================ [API REVIEWS] updateReview ================');
    debugPrint('📌 PUT Endpoint: $endpoint');
    debugPrint('📤 Body: $body');
    try {
      final response = await _client.put(
        endpoint,
        data: body,
        headers: _authHeader,
      );
      debugPrint('✅ Update Review Status: ${response.statusCode}');
      debugPrint('📄 Response Body: ${response.data}');
      debugPrint('=============================================================\n');
    } catch (e) {
      debugPrint('❌ [API REVIEWS ERROR] updateReview Failed!');
      debugPrint('🔴 Exception: $e');
      if (e is DioException) {
        debugPrint('   Status Code: ${e.response?.statusCode}');
        debugPrint('   Response Data: ${e.response?.data}');
      }
      debugPrint('=============================================================\n');
      rethrow;
    }
  }

  Future<void> deleteReview(int reviewId) async {
    final endpoint = ApiEndpoints.driverReviewById(reviewId);
    debugPrint('\n================ [API REVIEWS] deleteReview ================');
    debugPrint('📌 DELETE Endpoint: $endpoint');
    try {
      final response = await _client.delete(
        endpoint,
        headers: _authHeader,
      );
      debugPrint('✅ Delete Review Status: ${response.statusCode}');
      debugPrint('📄 Response Body: ${response.data}');
      debugPrint('=============================================================\n');
    } catch (e) {
      debugPrint('❌ [API REVIEWS ERROR] deleteReview Failed!');
      debugPrint('🔴 Exception: $e');
      if (e is DioException) {
        debugPrint('   Status Code: ${e.response?.statusCode}');
        debugPrint('   Response Data: ${e.response?.data}');
      }
      debugPrint('=============================================================\n');
      rethrow;
    }
  }
}

