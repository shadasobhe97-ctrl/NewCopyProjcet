import '../models/driver_preferences_model.dart';
import '../models/zone_model.dart';

abstract class DriverPreferencesRepository {
  Future<DriverPreferencesModel?> getPreferences();
  Future<bool> savePreferences({
    required int shift,
    required String subscriptionType,
    required List<int> zoneIds,
  });
  Future<List<Zone>> getZones();
}
