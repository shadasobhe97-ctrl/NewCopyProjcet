import '../datasources/driver_emergency_remote_data_source.dart';
import '../models/emergency_dispatch_model.dart';

class DriverEmergencyRepository {
  final DriverEmergencyRemoteDataSource _remoteDataSource;

  DriverEmergencyRepository(this._remoteDataSource);

  Future<List<EmergencyDispatchModel>> getAvailableDispatches() async {
    return await _remoteDataSource.getAvailableDispatches();
  }

  Future<EmergencyDispatchModel> getDispatchDetails(int dispatchId) async {
    return await _remoteDataSource.getDispatchDetails(dispatchId);
  }

  Future<Map<String, dynamic>> acceptDispatch(int dispatchId) async {
    return await _remoteDataSource.acceptDispatch(dispatchId);
  }

  Future<Map<String, dynamic>> rejectDispatch(int dispatchId) async {
    return await _remoteDataSource.rejectDispatch(dispatchId);
  }
}
