import '../datasources/complaints_remote_data_source.dart';
import '../models/complaint_model.dart';
import '../models/driver_trip_model.dart';

class ComplaintsRepository {
  final ComplaintsRemoteDataSource _remoteDataSource;

  ComplaintsRepository(this._remoteDataSource);

  Future<List<ComplaintModel>> getComplaints({String? type}) async {
    return await _remoteDataSource.getComplaints(type: type);
  }

  Future<ComplaintModel> getComplaintDetails(int id) async {
    return await _remoteDataSource.getComplaintDetails(id);
  }

  Future<ComplaintModel> createComplaint({
    required int driverId,
    required int tripId,
    required String description,
  }) async {
    return await _remoteDataSource.createComplaint(
      driverId: driverId,
      tripId: tripId,
      description: description,
    );
  }

  Future<ComplaintModel> updateComplaint({
    required int id,
    required String description,
    int? tripId,
  }) async {
    return await _remoteDataSource.updateComplaint(
      id: id,
      description: description,
      tripId: tripId,
    );
  }

  Future<void> deleteComplaint(int id) async {
    await _remoteDataSource.deleteComplaint(id);
  }

  Future<List<DriverTripModel>> getDriverTrips(int driverId) async {
    return await _remoteDataSource.getDriverTrips(driverId);
  }
}
