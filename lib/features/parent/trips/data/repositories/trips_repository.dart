import '../datasources/trips_remote_data_source.dart';
import '../models/active_trip_model.dart';
import '../models/trip_track_model.dart';
import '../models/upcoming_trip_model.dart';
import '../models/trip_history_model.dart';

class TripsRepository {
  final TripsRemoteDataSource _remoteDataSource;

  TripsRepository(this._remoteDataSource);

  Future<List<ActiveTripModel>> getActiveTrips() async {
    return await _remoteDataSource.getActiveTrips();
  }

  Future<TripTrackModel> getTripTrack(int tripId) async {
    return await _remoteDataSource.getTripTrack(tripId);
  }

  Future<List<UpcomingTripModel>> getUpcomingTrips() async {
    return await _remoteDataSource.getUpcomingTrips();
  }

  Future<List<TripHistoryModel>> getTripHistory(int page) async {
    return await _remoteDataSource.getTripHistory(page);
  }
}
