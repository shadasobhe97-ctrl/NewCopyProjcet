part of 'driver_requests_cubit.dart';

abstract class DriverRequestsState {}

class DriverRequestsInitial extends DriverRequestsState {}

class DriverRequestsLoading extends DriverRequestsState {}

class DriverRequestsLoaded extends DriverRequestsState {
  final List<DriverRequestModel> requests;
  final DriverRequestsFilter activeFilter;

  DriverRequestsLoaded({
    required this.requests,
    required this.activeFilter,
  });
}

class DriverRequestsError extends DriverRequestsState {
  final String message;
  DriverRequestsError(this.message);
}
