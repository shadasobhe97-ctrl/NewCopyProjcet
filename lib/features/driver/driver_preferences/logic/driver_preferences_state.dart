import '../data/models/driver_preferences_model.dart';
import '../data/models/zone_model.dart';

abstract class DriverPreferencesState {
  const DriverPreferencesState();
}

class DriverPreferencesInitial extends DriverPreferencesState {}

class DriverPreferencesLoading extends DriverPreferencesState {}

class DriverPreferencesLoadSuccess extends DriverPreferencesState {
  final DriverPreferencesModel? preferences;
  final List<Zone> zones;

  const DriverPreferencesLoadSuccess({
    this.preferences,
    required this.zones,
  });
}

class DriverPreferencesSaveLoading extends DriverPreferencesState {}

class DriverPreferencesSaveSuccess extends DriverPreferencesState {}

class DriverPreferencesError extends DriverPreferencesState {
  final String message;

  const DriverPreferencesError(this.message);
}
