import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/trips_repository.dart';
import '../../data/models/active_trip_model.dart';
import 'trip_tracking_state.dart';

class TripTrackingCubit extends Cubit<TripTrackingState> {
  final TripsRepository _repository;
  Timer? _timer;
  dynamic _currentTripId;
  bool _isMultiMode = false;
  List<ActiveTripModel> _allActiveTrips = [];

  TripTrackingCubit(this._repository) : super(TripTrackingInitial());

  void setAllActiveTrips(List<ActiveTripModel> trips) {
    _allActiveTrips = trips;
  }

  void startTracking(dynamic tripId, {ActiveTripModel? activeTrip, int? childId}) {
    _isMultiMode = false;
    _currentTripId = tripId;
    _timer?.cancel();
    emit(TripTrackingLoading());
    
    _fetchSingleTrack(tripId, activeTrip: activeTrip, childId: childId);

    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchSingleTrack(tripId, activeTrip: activeTrip, childId: childId);
    });
  }

  void startMultiTracking({List<ActiveTripModel>? activeTrips}) {
    _isMultiMode = true;
    _currentTripId = null;
    if (activeTrips != null && activeTrips.isNotEmpty) {
      _allActiveTrips = activeTrips;
    }
    _timer?.cancel();
    emit(TripTrackingLoading());

    _fetchMultiTrack();

    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchMultiTrack();
    });
  }

  Future<void> refresh() async {
    if (_isMultiMode) {
      await _fetchMultiTrack();
    } else if (_currentTripId != null) {
      await _fetchSingleTrack(_currentTripId);
    }
  }

  Future<void> _fetchSingleTrack(dynamic tripId, {ActiveTripModel? activeTrip, int? childId}) async {
    try {
      final trackData = await _repository.getTripTrack(tripId);
      
      ActiveTripModel? matchedTrip = activeTrip;
      if (matchedTrip == null && _allActiveTrips.isNotEmpty) {
        try {
          matchedTrip = _allActiveTrips.firstWhere((t) => t.tripId == tripId);
        } catch (_) {}
      }

      // Check for offline / stale location
      bool isOffline = !trackData.isOnline;
      String? offlineMsg;
      if (isOffline) {
        offlineMsg = 'انقطع الاتصال بالسائق. آخر تحديث: ${trackData.lastUpdated}';
      }

      emit(TripTrackingSingleLoaded(
        trackData: trackData,
        activeTrip: matchedTrip,
        selectedChildId: childId,
        isOffline: isOffline,
        offlineMessage: offlineMsg,
      ));
    } catch (e) {
      if (state is! TripTrackingSingleLoaded) {
        emit(TripTrackingError(e.toString()));
      }
    }
  }

  Future<void> _fetchMultiTrack() async {
    try {
      final tracks = await _repository.getMultipleActiveTracking();
      emit(TripTrackingMultiLoaded(
        tracks: tracks,
        activeTrips: _allActiveTrips,
      ));
    } catch (e) {
      if (state is! TripTrackingMultiLoaded) {
        emit(TripTrackingError(e.toString()));
      }
    }
  }

  void stopTracking() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Future<void> close() {
    stopTracking();
    return super.close();
  }
}
