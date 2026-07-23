import 'package:equatable/equatable.dart';
import '../../data/models/trip_history_model.dart';

abstract class TripHistoryState extends Equatable {
  const TripHistoryState();

  @override
  List<Object?> get props => [];
}

class TripHistoryInitial extends TripHistoryState {}

class TripHistoryLoading extends TripHistoryState {}

class TripHistoryLoaded extends TripHistoryState {
  final List<TripHistoryModel> historyTrips;
  final int currentPage;
  final bool hasMore;

  const TripHistoryLoaded({
    required this.historyTrips,
    required this.currentPage,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [historyTrips, currentPage, hasMore];
}

class TripHistoryError extends TripHistoryState {
  final String message;

  const TripHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
