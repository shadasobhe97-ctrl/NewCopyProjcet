import '../datasources/trips_remote_data_source.dart';
import '../models/active_trip_model.dart';
import '../models/trip_track_model.dart';
import '../models/upcoming_trip_model.dart';
import '../models/trip_history_model.dart';
import '../models/trip_details_model.dart';
import '../models/trip_timeline_model.dart';
import '../models/child_trips_model.dart';

class TripsRepository {
  final TripsRemoteDataSource _remoteDataSource;

  TripsRepository(this._remoteDataSource);

  Future<List<ActiveTripModel>> getActiveTrips() async {
    return await _remoteDataSource.getActiveTrips();
  }

  Future<LiveTrackingModel> getTripTrack(dynamic tripId) async {
    return await _remoteDataSource.getTripTrack(tripId);
  }

  Future<List<LiveTrackingModel>> getMultipleActiveTracking() async {
    return await _remoteDataSource.getMultipleActiveTracking();
  }

  Future<List<UpcomingTripModel>> getUpcomingTrips() async {
    return await _remoteDataSource.getUpcomingTrips();
  }

  Future<List<TripHistoryModel>> getTripHistory(int page) async {
    return await _remoteDataSource.getTripHistory(page);
  }

  Future<TripDetailsModel> getTripDetails(dynamic tripId) async {
    return await _remoteDataSource.getTripDetails(tripId);
  }

  Future<List<TripTimelineItemModel>> getTripTimeline(dynamic tripId) async {
    return await _remoteDataSource.getTripTimeline(tripId);
  }

  Future<ChildTripsModel> getChildTrips(dynamic childId) async {
    return await _remoteDataSource.getChildTrips(childId);
  }

  Future<Map<String, dynamic>> getChildStatus(dynamic tripId, dynamic childId) async {
    return await _remoteDataSource.getChildStatus(tripId, childId);
  }
}
