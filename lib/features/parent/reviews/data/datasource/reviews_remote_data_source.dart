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
    final response = await _client.get(
      ApiEndpoints.checkSubscription(driverId),
      headers: _authHeader,
    );
    return SubscriptionCheckModel.fromJson(
      response.data as Map<String, dynamic>,
    );
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
      data: {'driver_id': driverId, 'rating': rating, 'comment': comment},
      headers: _authHeader,
    );
  }

  Future<void> updateReview({
    required int reviewId,
    required int rating,
    required String comment,
  }) async {
    await _client.put(
      ApiEndpoints.driverReviewById(reviewId),
      data: {'rating': rating, 'comment': comment},
      headers: _authHeader,
    );
  }

  Future<void> deleteReview(int reviewId) async {
    await _client.delete(
      ApiEndpoints.driverReviewById(reviewId),
      headers: _authHeader,
    );
  }
}
