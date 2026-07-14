import '../datasources/driver_preferences_remote_data_source.dart';
import '../models/driver_preferences_model.dart';
import '../models/zone_model.dart';
import '../repositories/driver_preferences_repository.dart';

class DriverPreferencesRepositoryImpl implements DriverPreferencesRepository {
  final DriverPreferencesRemoteDataSource _remoteDataSource;

  DriverPreferencesRepositoryImpl(this._remoteDataSource);

  @override
  Future<DriverPreferencesModel?> getPreferences() {
    return _remoteDataSource.getPreferences();
  }

  @override
  Future<bool> savePreferences({
    required int shift,
    required String subscriptionType,
    required List<int> zoneIds,
  }) {
    return _remoteDataSource.savePreferences(
      shift: shift,
      subscriptionType: subscriptionType,
      zoneIds: zoneIds,
    );
  }

  @override
  Future<List<Zone>> getZones() {
    return _remoteDataSource.getZones();
  }
}
