import 'package:dio/dio.dart';
import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import '../models/review_model.dart';
import '../models/subscription_check_model.dart';

class ReviewsRemoteDataSource {
  final ApiClient _client;

  ReviewsRemoteDataSource(this._client);

  Map<String, dynamic> get _authHeader {
    final token = StorageService.getAuthorizationHeader();
    return {'Authorization': token ?? ''};
  }

  Future<SubscriptionCheckModel> checkSubscription(int driverId) async {
    final response = await _client.get(
      ApiEndpoints.checkSubscription(driverId),
      headers: _authHeader,
    );
    return SubscriptionCheckModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ReviewsResponse> getReviews(int driverId, int page) async {
    final response = await _client.get(
      '${ApiEndpoints.getDriverReviews(driverId)}?page=$page',
      headers: _authHeader,
    );
    return ReviewsResponse.fromJson(response.data);
  }

  Future<void> postReview({
    required int driverId,
    required int rating,
    required String comment,
  }) async {
    await _client.post(
      ApiEndpoints.driverReviews,
      data: {
        'driver_id': driverId,
        'rating': rating,
        'comment': comment,
      },
      headers: _authHeader,
    );
  }

  Future<void> updateReview({
    required int reviewId,
    required int rating,
    required String comment,
  }) async {
    // API client expects put/patch or we can use post or custom method. Let's see if ApiClient has put or we can use dio directly.
    // Wait, ApiClient has post, get, and delete. If ApiClient doesn't have put, we can use client.dio.put!
    // Let's verify ApiClient definition again. Yes, ApiClient has 'post', 'get', 'delete'. It does NOT have a custom 'put' wrapper, but it exposes '_dio' or 'dio'.
    // Let's look: `Dio get dio => _dio;` in ApiClient.
    // So we can use `_client.dio.put(...)` directly! Or we can call `_client.dio.put(...)` and handle exceptions, or check if ApiClient has put.
    // Wait, let's write a standard Dio call via client.dio.put!
    await _client.dio.put(
      ApiEndpoints.driverReviewById(reviewId),
      data: {
        'rating': rating,
        'comment': comment,
      },
      options: Options(headers: _authHeader),
    );
  }

  Future<void> deleteReview(int reviewId) async {
    await _client.delete(
      ApiEndpoints.driverReviewById(reviewId),
      headers: _authHeader,
    );
  }
}
