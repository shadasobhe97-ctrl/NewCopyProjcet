import 'package:kids_transport/features/driver/driver_preferences/data/models/zone_model.dart';
import '../data/models/driver_address_model.dart';

abstract class DriverAddressState {}

class DriverAddressInitial extends DriverAddressState {}

class DriverAddressLoading extends DriverAddressState {}

class DriverAddressLoaded extends DriverAddressState {
  final DriverAddressModel? address;
  final List<ZoneModel> zones;

  DriverAddressLoaded({
    required this.address,
    required this.zones,
  });

  DriverAddressLoaded copyWith({
    DriverAddressModel? address,
    List<ZoneModel>? zones,
  }) {
    return DriverAddressLoaded(
      address: address ?? this.address,
      zones: zones ?? this.zones,
    );
  }
}

class DriverAddressError extends DriverAddressState {
  final String message;
  DriverAddressError(this.message);
}

class DriverAddressSaving extends DriverAddressState {
  final DriverAddressModel? currentAddress;
  final List<ZoneModel> zones;
  DriverAddressSaving({this.currentAddress, required this.zones});
}

class DriverAddressSaveSuccess extends DriverAddressState {
  final String message;
  final DriverAddressModel address;
  final List<ZoneModel> zones;

  DriverAddressSaveSuccess({
    required this.message,
    required this.address,
    required this.zones,
  });
}

class DriverAddressSaveError extends DriverAddressState {
  final String errorMessage;
  final DriverAddressModel? currentAddress;
  final List<ZoneModel> zones;

  DriverAddressSaveError({
    required this.errorMessage,
    this.currentAddress,
    required this.zones,
  });
}
