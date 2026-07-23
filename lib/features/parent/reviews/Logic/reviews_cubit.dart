import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/reviews_repository.dart';
import '../data/models/review_model.dart';
import 'reviews_state.dart';

class ReviewsCubit extends Cubit<ReviewsState> {
  final ReviewsRepository _repository;
  bool _isLoadingMore = false;

  ReviewsCubit(this._repository) : super(ReviewsInitial());

  Future<void> loadReviews(int driverId) async {
    emit(ReviewsLoading());
    try {
      // Parallel calls: checkSubscription and getReviews
      final results = await Future.wait([
        _repository.getReviews(driverId, 1),
        _repository.checkSubscription(driverId),
      ]);

      final reviewsRes = results[0] as ReviewsResponse;
      final checkRes = results[1] as dynamic; // SubscriptionCheckModel

      final hasSub = checkRes.hasSubscription == true;

      emit(
        ReviewsLoaded(
          reviews: reviewsRes.reviews,
          hasSubscription: hasSub,
          currentPage: 1,
          hasMore: reviewsRes.hasMore,
        ),
      );
    } catch (e) {
      emit(ReviewsError(_parseError(e)));
    }
  }

  Future<void> loadMoreReviews(int driverId) async {
    final currentState = state;
    if (currentState is! ReviewsLoaded ||
        _isLoadingMore ||
        !currentState.hasMore) {
      return;
    }

    _isLoadingMore = true;
    final nextPage = currentState.currentPage + 1;

    try {
      final reviewsRes = await _repository.getReviews(driverId, nextPage);

      emit(
        ReviewsLoaded(
          reviews: [...currentState.reviews, ...reviewsRes.reviews],
          hasSubscription: currentState.hasSubscription,
          currentPage: nextPage,
          hasMore: reviewsRes.hasMore,
        ),
      );
    } catch (e) {
      // Maintain current state, just stop loading more
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> addReview({
    required int driverId,
    required int rating,
    required String comment,
  }) async {
    final currentState = state;
    List<ReviewModel> currentList = [];
    bool hasSub = false;

    if (currentState is ReviewsLoaded) {
      currentList = currentState.reviews;
      hasSub = currentState.hasSubscription;
    }

    emit(ReviewsSubmitting(reviews: currentList, hasSubscription: hasSub));
    try {
      await _repository.postReview(
        driverId: driverId,
        rating: rating,
        comment: comment,
      );

      emit(const ReviewsSuccess('تم إضافة تقييمك بنجاح'));
      // Reload reviews
      await loadReviews(driverId);
    } catch (e) {
      emit(ReviewsError(_parseError(e)));
      if (currentList.isNotEmpty) {
        emit(
          ReviewsLoaded(
            reviews: currentList,
            hasSubscription: hasSub,
            currentPage: (currentState as ReviewsLoaded).currentPage,
            hasMore: currentState.hasMore,
          ),
        );
      }
    }
  }

  Future<void> editReview({
    required int driverId,
    required int reviewId,
    required int rating,
    required String comment,
  }) async {
    final currentState = state;
    List<ReviewModel> currentList = [];
    bool hasSub = false;

    if (currentState is ReviewsLoaded) {
      currentList = currentState.reviews;
      hasSub = currentState.hasSubscription;
    }

    emit(ReviewsSubmitting(reviews: currentList, hasSubscription: hasSub));
    try {
      await _repository.updateReview(
        reviewId: reviewId,
        rating: rating,
        comment: comment,
      );

      emit(const ReviewsSuccess('تم تعديل تقييمك بنجاح'));
      // Reload reviews
      await loadReviews(driverId);
    } catch (e) {
      emit(ReviewsError(_parseError(e)));
      if (currentList.isNotEmpty) {
        emit(
          ReviewsLoaded(
            reviews: currentList,
            hasSubscription: hasSub,
            currentPage: (currentState as ReviewsLoaded).currentPage,
            hasMore: currentState.hasMore,
          ),
        );
      }
    }
  }

  Future<void> deleteReview({
    required int driverId,
    required int reviewId,
  }) async {
    final currentState = state;
    List<ReviewModel> currentList = [];
    bool hasSub = false;

    if (currentState is ReviewsLoaded) {
      currentList = currentState.reviews;
      hasSub = currentState.hasSubscription;
    }

    emit(ReviewsSubmitting(reviews: currentList, hasSubscription: hasSub));
    try {
      await _repository.deleteReview(reviewId);

      emit(const ReviewsSuccess('تم حذف التقييم بنجاح'));
      // Reload reviews
      await loadReviews(driverId);
    } catch (e) {
      emit(ReviewsError(_parseError(e)));
      if (currentList.isNotEmpty) {
        emit(
          ReviewsLoaded(
            reviews: currentList,
            hasSubscription: hasSub,
            currentPage: (currentState as ReviewsLoaded).currentPage,
            hasMore: currentState.hasMore,
          ),
        );
      }
    }
  }

  String _parseError(dynamic e) {
    if (e is DioException) {
      if (e.response != null) {
        final code = e.response!.statusCode;
        final data = e.response!.data;
        if (data is Map && data['message'] != null) {
          return data['message'].toString();
        }
        switch (code) {
          case 401:
            return 'غير مصرح لك بالوصول. يرجى تسجيل الدخول مجدداً.';
          case 403:
            return 'ليس لديك صلاحية لإجراء هذه العملية.';
          case 404:
            return 'لم يتم العثور على المورد المطلوب.';
          case 422:
            return 'البيانات المرسلة غير صالحة. يرجى التحقق من المدخلات.';
          case 500:
            return 'حدث خطأ في الخادم الداخلي. يرجى المحاولة لاحقاً.';
          default:
            return 'خطأ في الاتصال بالخادم ($code)';
        }
      }
      return 'فشل الاتصال بالإنترنت. يرجى التحقق من الشبكة.';
    }
    return e.toString().replaceAll('Exception:', '');
  }
}
