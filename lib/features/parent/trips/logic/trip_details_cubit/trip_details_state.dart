import 'package:equatable/equatable.dart';
import '../../data/models/trip_details_model.dart';

abstract class TripDetailsState extends Equatable {
  const TripDetailsState();

  @override
  List<Object?> get props => [];
}

class TripDetailsInitial extends TripDetailsState {}

class TripDetailsLoading extends TripDetailsState {}

class TripDetailsLoaded extends TripDetailsState {
  final TripDetailsModel tripDetails;

  const TripDetailsLoaded(this.tripDetails);

  @override
  List<Object?> get props => [tripDetails];
}

class TripDetailsError extends TripDetailsState {
  final String message;

  const TripDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
