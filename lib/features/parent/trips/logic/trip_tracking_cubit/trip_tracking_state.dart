import 'package:equatable/equatable.dart';
import '../../data/models/trip_track_model.dart';
import '../../data/models/active_trip_model.dart';

abstract class TripTrackingState extends Equatable {
  const TripTrackingState();

  @override
  List<Object?> get props => [];
}

class TripTrackingInitial extends TripTrackingState {}

class TripTrackingLoading extends TripTrackingState {}

class TripTrackingSingleLoaded extends TripTrackingState {
  final LiveTrackingModel trackData;
  final ActiveTripModel? activeTrip;
  final int? selectedChildId;
  final bool isOffline;
  final String? offlineMessage;

  const TripTrackingSingleLoaded({
    required this.trackData,
    this.activeTrip,
    this.selectedChildId,
    this.isOffline = false,
    this.offlineMessage,
  });

  @override
  List<Object?> get props => [trackData, activeTrip, selectedChildId, isOffline, offlineMessage];
}

class TripTrackingMultiLoaded extends TripTrackingState {
  final List<LiveTrackingModel> tracks;
  final List<ActiveTripModel> activeTrips;
  final bool isOffline;

  const TripTrackingMultiLoaded({
    required this.tracks,
    required this.activeTrips,
    this.isOffline = false,
  });

  @override
  List<Object?> get props => [tracks, activeTrips, isOffline];
}

// Backward compatibility alias for single loaded state
typedef TripTrackingLoaded = TripTrackingSingleLoaded;

class TripTrackingError extends TripTrackingState {
  final String message;

  const TripTrackingError(this.message);

  @override
  List<Object?> get props => [message];
}
