import 'package:equatable/equatable.dart';
import 'package:kids_transport/features/parent/reviews/data/models/review_model.dart';

abstract class ReviewsState extends Equatable {
  const ReviewsState();

  @override
  List<Object?> get props => [];
}

class ReviewsInitial extends ReviewsState {}

class ReviewsLoading extends ReviewsState {}

class ReviewsLoaded extends ReviewsState {
  final List<ReviewModel> reviews;
  final bool hasSubscription;
  final int currentPage;
  final bool hasMore;

  const ReviewsLoaded({
    required this.reviews,
    required this.hasSubscription,
    required this.currentPage,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [reviews, hasSubscription, currentPage, hasMore];
}

class ReviewsSubmitting extends ReviewsState {
  final List<ReviewModel> reviews;
  final bool hasSubscription;

  const ReviewsSubmitting({
    required this.reviews,
    required this.hasSubscription,
  });

  @override
  List<Object?> get props => [reviews, hasSubscription];
}

class ReviewsSuccess extends ReviewsState {
  final String message;

  const ReviewsSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ReviewsError extends ReviewsState {
  final String message;

  const ReviewsError(this.message);

  @override
  List<Object?> get props => [message];
}
