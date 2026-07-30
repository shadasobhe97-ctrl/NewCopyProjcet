import 'package:equatable/equatable.dart';
import '../../data/models/child_trips_model.dart';

abstract class ChildTripsState extends Equatable {
  const ChildTripsState();

  @override
  List<Object?> get props => [];
}

class ChildTripsInitial extends ChildTripsState {}

class ChildTripsLoading extends ChildTripsState {}

class ChildTripsLoaded extends ChildTripsState {
  final ChildTripsModel childTrips;

  const ChildTripsLoaded(this.childTrips);

  @override
  List<Object?> get props => [childTrips];
}

class ChildTripsError extends ChildTripsState {
  final String message;

  const ChildTripsError(this.message);

  @override
  List<Object?> get props => [message];
}
