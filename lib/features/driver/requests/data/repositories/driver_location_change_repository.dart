import '../../../../parent/location_change/data/models/location_change_request_model.dart';
import '../datasources/driver_location_change_remote_data_source.dart';

class DriverLocationChangeRepository {
  final DriverLocationChangeRemoteDataSource _remoteDataSource;

  DriverLocationChangeRepository(this._remoteDataSource);

  Future<List<LocationChangeRequestModel>> getRequests({String? status}) async {
    return await _remoteDataSource.getRequests(status: status);
  }

  Future<Map<String, dynamic>> respondToRequest(
    int id, {
    required String status,
    String? rejectionReason,
  }) async {
    return await _remoteDataSource.respondToRequest(
      id,
      status: status,
      rejectionReason: rejectionReason,
    );
  }
}
