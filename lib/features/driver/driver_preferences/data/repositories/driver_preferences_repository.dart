import '../models/driver_preferences_model.dart';
import '../models/preference_defaults_model.dart';

abstract class DriverPreferencesRepository {
  Future<PreferenceDefaultsModel> getPreferenceDefaults();
  Future<DriverPreferencesModel?> getPreferences();
  Future<bool> updatePreferences(Map<String, dynamic> payload);
}
