import 'package:equatable/equatable.dart';
import '../data/models/complaint_model.dart';
import '../data/models/driver_trip_model.dart';

abstract class ComplaintsState extends Equatable {
  const ComplaintsState();

  @override
  List<Object?> get props => [];
}

class ComplaintsInitial extends ComplaintsState {}

class ComplaintsLoading extends ComplaintsState {}

class ComplaintsLoaded extends ComplaintsState {
  final List<ComplaintModel> complaints;
  final String activeType; // 'all', 'pending', 'action_taken'

  const ComplaintsLoaded({
    required this.complaints,
    this.activeType = 'all',
  });

  @override
  List<Object?> get props => [complaints, activeType];
}

class ComplaintDetailsLoading extends ComplaintsState {}

class ComplaintDetailsLoaded extends ComplaintsState {
  final ComplaintModel complaint;

  const ComplaintDetailsLoaded(this.complaint);

  @override
  List<Object?> get props => [complaint];
}

class DriverTripsLoading extends ComplaintsState {}

class DriverTripsLoaded extends ComplaintsState {
  final List<DriverTripModel> trips;

  const DriverTripsLoaded(this.trips);

  @override
  List<Object?> get props => [trips];
}

class ComplaintSubmitting extends ComplaintsState {
  final List<ComplaintModel> currentComplaints;

  const ComplaintSubmitting({this.currentComplaints = const []});

  @override
  List<Object?> get props => [currentComplaints];
}

class ComplaintSuccess extends ComplaintsState {
  final String message;
  final ComplaintModel? complaint;

  const ComplaintSuccess(this.message, {this.complaint});

  @override
  List<Object?> get props => [message, complaint];
}

class ComplaintsError extends ComplaintsState {
  final String message;

  const ComplaintsError(this.message);

  @override
  List<Object?> get props => [message];
}
