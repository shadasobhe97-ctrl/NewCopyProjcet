import '../datasources/driver_statistics_remote_datasource.dart';
import '../models/driver_statistics_model.dart';

class DriverStatisticsRepository {
  final DriverStatisticsRemoteDataSource _remoteDataSource;

  DriverStatisticsRepository(this._remoteDataSource);

  Future<DriverStatisticsModel> getDriverStatistics({
    int? month,
    int? year,
  }) async {
    return await _remoteDataSource.getDriverStatistics(
      month: month,
      year: year,
    );
  }
}
