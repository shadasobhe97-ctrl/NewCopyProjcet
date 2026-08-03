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
  final int perPage;
  final int total;
  final bool hasMore;
  final int? selectedChildId;
  final String? selectedDate;
  final String selectedDirection; // 'all', 'to_school', 'to_home'

  const TripHistoryLoaded({
    required this.historyTrips,
    required this.currentPage,
    this.perPage = 15,
    this.total = 0,
    required this.hasMore,
    this.selectedChildId,
    this.selectedDate,
    this.selectedDirection = 'all',
  });

  List<TripHistoryModel> get filteredTrips {
    return historyTrips.where((trip) {
      if (selectedChildId != null && selectedChildId != 0) {
        final matchesChild = trip.children.any((c) => c.childId == selectedChildId);
        if (!matchesChild) return false;
      }
      if (selectedDate != null && selectedDate!.isNotEmpty) {
        if (!trip.tripDate.contains(selectedDate!)) return false;
      }
      if (selectedDirection != 'all' && selectedDirection.isNotEmpty) {
        if (trip.direction != selectedDirection && trip.tripType != selectedDirection) return false;
      }
      return true;
    }).toList();
  }

  TripHistoryLoaded copyWith({
    List<TripHistoryModel>? historyTrips,
    int? currentPage,
    int? perPage,
    int? total,
    bool? hasMore,
    int? selectedChildId,
    String? selectedDate,
    String? selectedDirection,
  }) {
    return TripHistoryLoaded(
      historyTrips: historyTrips ?? this.historyTrips,
      currentPage: currentPage ?? this.currentPage,
      perPage: perPage ?? this.perPage,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      selectedChildId: selectedChildId ?? this.selectedChildId,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedDirection: selectedDirection ?? this.selectedDirection,
    );
  }

  @override
  List<Object?> get props => [
        historyTrips,
        currentPage,
        perPage,
        total,
        hasMore,
        selectedChildId,
        selectedDate,
        selectedDirection,
      ];
}

class TripHistoryError extends TripHistoryState {
  final String message;

  const TripHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
