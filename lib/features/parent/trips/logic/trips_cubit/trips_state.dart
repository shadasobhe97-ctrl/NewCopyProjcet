import 'package:equatable/equatable.dart';
import '../../data/models/active_trip_model.dart';
import '../../data/models/upcoming_trip_model.dart';
import '../../data/models/trip_history_model.dart';

abstract class TripsState extends Equatable {
  const TripsState();

  @override
  List<Object?> get props => [];
}

class TripsInitial extends TripsState {}

class TripsLoading extends TripsState {}

class TripsLoaded extends TripsState {
  final List<ActiveTripModel> activeTrips;
  final List<UpcomingTripModel> upcomingTrips;
  final List<TripHistoryModel> historyTrips;
  final int? selectedChildId;
  final String selectedChildName;

  const TripsLoaded({
    required this.activeTrips,
    required this.upcomingTrips,
    required this.historyTrips,
    this.selectedChildId,
    this.selectedChildName = 'جميع الأطفال',
  });

  // Filtered lists based on selectedChildId
  List<ActiveTripModel> get filteredActiveTrips {
    if (selectedChildId == null) return activeTrips;
    return activeTrips.where((t) => t.children.any((c) => c.childId == selectedChildId)).toList();
  }

  List<UpcomingTripModel> get filteredUpcomingTrips {
    if (selectedChildId == null) return upcomingTrips;
    return upcomingTrips.where((t) => t.children.any((c) => c.childId == selectedChildId)).toList();
  }

  List<TripHistoryModel> get filteredHistoryTrips {
    if (selectedChildId == null) return historyTrips;
    return historyTrips.where((t) => t.children.any((c) => c.childId == selectedChildId)).toList();
  }

  TripsLoaded copyWith({
    List<ActiveTripModel>? activeTrips,
    List<UpcomingTripModel>? upcomingTrips,
    List<TripHistoryModel>? historyTrips,
    int? selectedChildId,
    String? selectedChildName,
    bool clearChildFilter = false,
  }) {
    return TripsLoaded(
      activeTrips: activeTrips ?? this.activeTrips,
      upcomingTrips: upcomingTrips ?? this.upcomingTrips,
      historyTrips: historyTrips ?? this.historyTrips,
      selectedChildId: clearChildFilter ? null : (selectedChildId ?? this.selectedChildId),
      selectedChildName: clearChildFilter ? 'جميع الأطفال' : (selectedChildName ?? this.selectedChildName),
    );
  }

  @override
  List<Object?> get props => [
        activeTrips,
        upcomingTrips,
        historyTrips,
        selectedChildId,
        selectedChildName,
      ];
}

class TripsError extends TripsState {
  final String message;

  const TripsError(this.message);

  @override
  List<Object?> get props => [message];
}
