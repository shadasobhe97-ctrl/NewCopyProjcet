import 'package:flutter/foundation.dart';
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
    debugPrint('\n🔍 [ReviewsCubit] loadReviews triggered for driverId: $driverId');
    if (state is ReviewsLoading) {
      debugPrint('⚠️ [ReviewsCubit] loadReviews skipped: state is already ReviewsLoading');
      return;
    }
    emit(ReviewsLoading());

    ReviewsResponse? reviewsRes;
    bool hasSub = false;
    String? errorMessage;

    try {
      reviewsRes = await _repository.getReviews(driverId, 1);
      debugPrint('✨ [ReviewsCubit] getReviews succeeded (${reviewsRes.reviews.length} reviews fetched)');
    } catch (e) {
      errorMessage = _parseError(e);
      debugPrint('❌ [ReviewsCubit] getReviews failed: $e -> parsed: $errorMessage');
    }

    try {
      final checkRes = await _repository.checkSubscription(driverId);
      hasSub = checkRes.hasSubscription == true;
      debugPrint('✨ [ReviewsCubit] checkSubscription succeeded: hasSubscription = $hasSub');
    } catch (e) {
      hasSub = false;
      debugPrint('❌ [ReviewsCubit] checkSubscription failed with exception: $e. Defaulting hasSubscription to FALSE.');
    }

    if (reviewsRes != null) {
      debugPrint('✅ [ReviewsCubit] Emitting ReviewsLoaded (hasSubscription: $hasSub, reviewsCount: ${reviewsRes.reviews.length})');
      emit(
        ReviewsLoaded(
          reviews: reviewsRes.reviews,
          hasSubscription: hasSub,
          currentPage: 1,
          hasMore: reviewsRes.hasMore,
        ),
      );
    } else {
      debugPrint('❌ [ReviewsCubit] Emitting ReviewsError: $errorMessage');
      emit(ReviewsError(errorMessage ?? 'تعذر تحميل التقييمات'));
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
    debugPrint('🔍 [ReviewsCubit] loadMoreReviews page $nextPage for driverId: $driverId');

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
      debugPrint('❌ [ReviewsCubit] loadMoreReviews failed: $e');
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> addReview({
    required int driverId,
    required int rating,
    required String comment,
  }) async {
    debugPrint('\n🚀 [ReviewsCubit] addReview triggered: driverId=$driverId, rating=$rating, comment="$comment"');
    if (state is ReviewsSubmitting) {
      debugPrint('⚠️ [ReviewsCubit] addReview skipped: already submitting');
      return;
    }
    final currentState = state;
    List<ReviewModel> currentList = [];
    bool hasSub = false;

    if (currentState is ReviewsLoaded) {
      currentList = currentState.reviews;
      hasSub = currentState.hasSubscription;
      debugPrint('ℹ️ [ReviewsCubit] Current state is ReviewsLoaded (hasSub=$hasSub, currentCount=${currentList.length})');
    } else {
      debugPrint('ℹ️ [ReviewsCubit] Current state is: ${currentState.runtimeType}');
    }

    emit(ReviewsSubmitting(reviews: currentList, hasSubscription: hasSub));
    try {
      await _repository.postReview(
        driverId: driverId,
        rating: rating,
        comment: comment,
      );

      debugPrint('🎉 [ReviewsCubit] postReview succeeded! Emitting ReviewsSuccess and reloading reviews...');
      emit(const ReviewsSuccess('تم إضافة تقييمك بنجاح'));
      // Reload reviews
      await loadReviews(driverId);
    } catch (e) {
      final parsedErr = _parseError(e);
      debugPrint('💥 [ReviewsCubit] postReview failed with error: $e -> parsed: $parsedErr');
      emit(ReviewsError(parsedErr));
      if (currentState is ReviewsLoaded) {
        emit(
          ReviewsLoaded(
            reviews: currentList,
            hasSubscription: hasSub,
            currentPage: currentState.currentPage,
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
    debugPrint('\n🚀 [ReviewsCubit] editReview triggered: driverId=$driverId, reviewId=$reviewId, rating=$rating, comment="$comment"');
    if (state is ReviewsSubmitting) return;
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

      debugPrint('🎉 [ReviewsCubit] updateReview succeeded!');
      emit(const ReviewsSuccess('تم تعديل تقييمك بنجاح'));
      // Reload reviews
      await loadReviews(driverId);
    } catch (e) {
      final parsedErr = _parseError(e);
      debugPrint('💥 [ReviewsCubit] updateReview failed: $e -> parsed: $parsedErr');
      emit(ReviewsError(parsedErr));
      if (currentState is ReviewsLoaded) {
        emit(
          ReviewsLoaded(
            reviews: currentList,
            hasSubscription: hasSub,
            currentPage: currentState.currentPage,
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
    debugPrint('\n🚀 [ReviewsCubit] deleteReview triggered: driverId=$driverId, reviewId=$reviewId');
    if (state is ReviewsSubmitting) return;
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

      debugPrint('🎉 [ReviewsCubit] deleteReview succeeded!');
      emit(const ReviewsSuccess('تم حذف التقييم بنجاح'));
      // Reload reviews
      await loadReviews(driverId);
    } catch (e) {
      final parsedErr = _parseError(e);
      debugPrint('💥 [ReviewsCubit] deleteReview failed: $e -> parsed: $parsedErr');
      emit(ReviewsError(parsedErr));
      if (currentState is ReviewsLoaded) {
        emit(
          ReviewsLoaded(
            reviews: currentList,
            hasSubscription: hasSub,
            currentPage: currentState.currentPage,
            hasMore: currentState.hasMore,
          ),
        );
      }
    }
  }

  String _parseError(dynamic e) {
    debugPrint('🔎 [ReviewsCubit] Parsing Exception: $e');
    if (e is DioException) {
      debugPrint('   DioException Type: ${e.type}');
      if (e.response != null) {
        final code = e.response!.statusCode;
        final data = e.response!.data;
        debugPrint('   StatusCode: $code');
        debugPrint('   Response Data: $data');
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

