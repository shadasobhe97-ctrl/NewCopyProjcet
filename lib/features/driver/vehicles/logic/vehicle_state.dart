import '../data/models/vehicle_model.dart';

abstract class VehicleState {}

class VehicleInitial extends VehicleState {}

class VehicleLoading extends VehicleState {}

class VehicleDetailsSuccess extends VehicleState {
  final VehicleModel vehicle;
  VehicleDetailsSuccess(this.vehicle);
}

class VehicleDocumentsSuccess extends VehicleState {
  final String message;
  VehicleDocumentsSuccess(this.message);
}

class VehicleError extends VehicleState {
  final String error;
  VehicleError(this.error);
}
