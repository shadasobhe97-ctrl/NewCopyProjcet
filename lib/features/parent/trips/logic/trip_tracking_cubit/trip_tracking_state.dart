import 'package:equatable/equatable.dart';
import '../../data/models/trip_track_model.dart';

abstract class TripTrackingState extends Equatable {
  const TripTrackingState();

  @override
  List<Object?> get props => [];
}

class TripTrackingInitial extends TripTrackingState {}

class TripTrackingLoading extends TripTrackingState {}

class TripTrackingLoaded extends TripTrackingState {
  final TripTrackModel trackData;

  const TripTrackingLoaded(this.trackData);

  @override
  List<Object?> get props => [trackData];
}

class TripTrackingError extends TripTrackingState {
  final String message;

  const TripTrackingError(this.message);

  @override
  List<Object?> get props => [message];
}
