import '../data_sources/driver_profile_remote_data_source.dart';
import '../models/driver_model.dart';

class DriverProfileRepository {
  final DriverProfileRemoteDataSource remoteDataSource;

  DriverProfileRepository({required this.remoteDataSource});

  Future<DriverModel> getDriverProfile() async {
    return await remoteDataSource.getDriverProfile();
  }

  Future<DriverModel> updateProfile({
    required String fullName,
    required String phoneNumber,
    String? alternativePhone,
    String? email,
  }) async {
    return await remoteDataSource.updateDriverProfile(
      fullName: fullName,
      phoneNumber: phoneNumber,
      alternativePhone: alternativePhone,
      email: email,
    );
  }
}
