import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/network/api_exception.dart';
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

  void startTracking(
    dynamic tripId, {
    ActiveTripModel? activeTrip,
    int? childId,
  }) {
    _isMultiMode = false;
    _currentTripId = tripId;
    _stopTimer();

    if (state is! TripTrackingSingleLoaded &&
        state is! TripTrackingMultiLoaded) {
      emit(TripTrackingLoading());
    }

    _fetchSingleTrack(
      tripId,
      activeTrip: activeTrip,
      childId: childId,
      isSilent: false,
    );

    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchSingleTrack(
        tripId,
        activeTrip: activeTrip,
        childId: childId,
        isSilent: true,
      );
    });
  }

  void startMultiTracking({List<ActiveTripModel>? activeTrips}) {
    _isMultiMode = true;
    _currentTripId = null;
    if (activeTrips != null && activeTrips.isNotEmpty) {
      _allActiveTrips = activeTrips;
    }
    _stopTimer();

    if (state is! TripTrackingMultiLoaded &&
        state is! TripTrackingSingleLoaded) {
      emit(TripTrackingLoading());
    }

    _fetchMultiTrack(isSilent: false);

    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchMultiTrack(isSilent: true);
    });
  }

  Future<void> refresh() async {
    if (_isMultiMode) {
      await _fetchMultiTrack(isSilent: false);
    } else if (_currentTripId != null) {
      await _fetchSingleTrack(_currentTripId, isSilent: false);
    }
  }

  Future<void> _fetchSingleTrack(
    dynamic tripId, {
    ActiveTripModel? activeTrip,
    int? childId,
    bool isSilent = false,
  }) async {
    try {
      final trackData = await _repository.getTripTrack(tripId);

      ActiveTripModel? matchedTrip = activeTrip;
      if (matchedTrip == null && _allActiveTrips.isNotEmpty) {
        try {
          matchedTrip = _allActiveTrips.firstWhere((t) => t.tripId == tripId);
        } catch (_) {}
      }

      bool isOffline = !trackData.isOnline;
      String? offlineMsg;
      if (isOffline) {
        offlineMsg =
            'انقطع الاتصال بالسائق. آخر تحديث: ${trackData.lastUpdated}';
      }

      emit(
        TripTrackingSingleLoaded(
          trackData: trackData,
          activeTrip: matchedTrip,
          selectedChildId: childId,
          isOffline: isOffline,
          offlineMessage: offlineMsg,
        ),
      );
    } catch (e) {
      if (state is TripTrackingSingleLoaded) {
        final current = state as TripTrackingSingleLoaded;
        emit(
          TripTrackingSingleLoaded(
            trackData: current.trackData,
            activeTrip: current.activeTrip,
            selectedChildId: current.selectedChildId,
            isOffline: true,
            offlineMessage: 'تعذر تحديث موقع الحافلة الآن (مشكلة اتصال)',
          ),
        );
      } else if (!isSilent) {
        final msg = (e is ApiException)
            ? e.message
            : e.toString().replaceAll('Exception:', '').trim();
        emit(TripTrackingError(msg));
      }
    }
  }

  Future<void> _fetchMultiTrack({bool isSilent = false}) async {
    try {
      final tracks = await _repository.getMultipleActiveTracking();
      emit(
        TripTrackingMultiLoaded(tracks: tracks, activeTrips: _allActiveTrips),
      );
    } catch (e) {
      if (state is TripTrackingMultiLoaded) {
        final current = state as TripTrackingMultiLoaded;
        emit(
          TripTrackingMultiLoaded(
            tracks: current.tracks,
            activeTrips: current.activeTrips,
            isOffline: true,
          ),
        );
      } else if (!isSilent) {
        final msg = (e is ApiException)
            ? e.message
            : e.toString().replaceAll('Exception:', '').trim();
        emit(TripTrackingError(msg));
      }
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void stopTracking() {
    _stopTimer();
  }

  @override
  Future<void> close() {
    _stopTimer();
    return super.close();
  }
}
