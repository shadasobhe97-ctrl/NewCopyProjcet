part of 'driver_trips_history_cubit.dart';

abstract class DriverTripsHistoryState extends Equatable {
  const DriverTripsHistoryState();

  @override
  List<Object?> get props => [];
}

class DriverTripsHistoryInitial extends DriverTripsHistoryState {}

class DriverTripsHistoryLoading extends DriverTripsHistoryState {}

class DriverTripsHistoryLoaded extends DriverTripsHistoryState {
  final List<DriverTripHistoryModel> trips;

  const DriverTripsHistoryLoaded(this.trips);

  @override
  List<Object?> get props => [trips];
}

class DriverTripsHistoryError extends DriverTripsHistoryState {
  final String message;

  const DriverTripsHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}

class DriverTripHistoryDetailsLoading extends DriverTripsHistoryState {}

class DriverTripHistoryDetailsLoaded extends DriverTripsHistoryState {
  final DriverTripHistoryDetailsModel details;

  const DriverTripHistoryDetailsLoaded(this.details);

  @override
  List<Object?> get props => [details];
}

class DriverTripHistoryDetailsError extends DriverTripsHistoryState {
  final String message;

  const DriverTripHistoryDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
