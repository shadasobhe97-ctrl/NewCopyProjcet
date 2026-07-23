import 'package:equatable/equatable.dart';
import '../../data/models/active_trip_model.dart';

abstract class ActiveTripState extends Equatable {
  const ActiveTripState();

  @override
  List<Object?> get props => [];
}

class ActiveTripInitial extends ActiveTripState {}

class ActiveTripLoading extends ActiveTripState {}

class ActiveTripLoaded extends ActiveTripState {
  final List<ActiveTripModel> activeTrips;

  const ActiveTripLoaded(this.activeTrips);

  @override
  List<Object?> get props => [activeTrips];
}

class ActiveTripError extends ActiveTripState {
  final String message;

  const ActiveTripError(this.message);

  @override
  List<Object?> get props => [message];
}
