import 'package:kids_transport/core/services/storage_service.dart';
import '../datasources/driver_preferences_remote_data_source.dart';
import '../models/driver_preferences_model.dart';
import '../models/preference_defaults_model.dart';
import '../repositories/driver_preferences_repository.dart';

class DriverPreferencesRepositoryImpl implements DriverPreferencesRepository {
  final DriverPreferencesRemoteDataSource _remoteDataSource;

  DriverPreferencesRepositoryImpl(this._remoteDataSource);

  @override
  Future<PreferenceDefaultsModel> getPreferenceDefaults() {
    return _remoteDataSource.getPreferenceDefaults();
  }

  @override
  Future<DriverPreferencesModel?> getPreferences() {
    return _remoteDataSource.getPreferences();
  }

  @override
  Future<bool> updatePreferences(Map<String, dynamic> payload) async {
    final success = await _remoteDataSource.updatePreferences(payload);
    if (success) {
      await StorageService.setIsPreferencesSet(true);
    }
    return success;
  }
}
