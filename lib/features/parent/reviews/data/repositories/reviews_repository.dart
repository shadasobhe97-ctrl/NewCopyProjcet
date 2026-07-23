import '../datasource/reviews_remote_data_source.dart';
import '../models/review_model.dart';
import '../models/subscription_check_model.dart';

class ReviewsRepository {
  final ReviewsRemoteDataSource _remoteDataSource;

  ReviewsRepository(this._remoteDataSource);

  Future<SubscriptionCheckModel> checkSubscription(int driverId) async {
    return await _remoteDataSource.checkSubscription(driverId);
  }

  Future<ReviewsResponse> getReviews(int driverId, int page) async {
    return await _remoteDataSource.getReviews(driverId, page);
  }

  Future<void> postReview({
    required int driverId,
    required int rating,
    required String comment,
  }) async {
    await _remoteDataSource.postReview(
      driverId: driverId,
      rating: rating,
      comment: comment,
    );
  }

  Future<void> updateReview({
    required int reviewId,
    required int rating,
    required String comment,
  }) async {
    await _remoteDataSource.updateReview(
      reviewId: reviewId,
      rating: rating,
      comment: comment,
    );
  }

  Future<void> deleteReview(int reviewId) async {
    await _remoteDataSource.deleteReview(reviewId);
  }
}
