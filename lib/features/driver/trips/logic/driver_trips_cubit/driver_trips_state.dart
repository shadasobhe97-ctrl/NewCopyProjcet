part of 'driver_trips_cubit.dart';

abstract class DriverTripsState extends Equatable {
  const DriverTripsState();

  @override
  List<Object?> get props => [];
}

class DriverTripsInitial extends DriverTripsState {}

class DriverTripsLoading extends DriverTripsState {}

class DriverTripsLoaded extends DriverTripsState {
  final List<DriverTripModel> trips;

  const DriverTripsLoaded(this.trips);

  @override
  List<Object?> get props => [trips];
}

class DriverTripsError extends DriverTripsState {
  final String message;

  const DriverTripsError(this.message);

  @override
  List<Object?> get props => [message];
}

class DriverTripDetailsLoading extends DriverTripsState {}

class DriverTripDetailsLoaded extends DriverTripsState {
  final DriverTripDetailsModel details;

  const DriverTripDetailsLoaded(this.details);

  @override
  List<Object?> get props => [details];
}

class DriverTripDetailsError extends DriverTripsState {
  final String message;

  const DriverTripDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
