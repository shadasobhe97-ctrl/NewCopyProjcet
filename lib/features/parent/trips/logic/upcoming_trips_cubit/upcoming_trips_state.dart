import 'package:equatable/equatable.dart';
import '../../data/models/upcoming_trip_model.dart';

abstract class UpcomingTripsState extends Equatable {
  const UpcomingTripsState();

  @override
  List<Object?> get props => [];
}

class UpcomingTripsInitial extends UpcomingTripsState {}

class UpcomingTripsLoading extends UpcomingTripsState {}

class UpcomingTripsLoaded extends UpcomingTripsState {
  final List<UpcomingTripModel> upcomingTrips;

  const UpcomingTripsLoaded(this.upcomingTrips);

  @override
  List<Object?> get props => [upcomingTrips];
}

class UpcomingTripsError extends UpcomingTripsState {
  final String message;

  const UpcomingTripsError(this.message);

  @override
  List<Object?> get props => [message];
}
