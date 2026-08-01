import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/trips_repository.dart';
import '../../data/models/active_trip_model.dart';
import '../../data/datasources/trips_mock_data.dart';
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

  /// 🌟 دالة البيانات الوهمية لتجربة الـ UI والتنقل الحقيقي
  void loadMockData({bool isEmpty = false}) {
    _stopTimer();
    emit(TripTrackingLoading());
    if (isEmpty) {
      _allActiveTrips = [];
      emit(const TripTrackingMultiLoaded(tracks: [], activeTrips: []));
    } else {
      _allActiveTrips = TripsMockData.activeTrips;
      _isMultiMode = true;
      emit(
        TripTrackingMultiLoaded(
          tracks: TripsMockData.multiTracking,
          activeTrips: _allActiveTrips,
        ),
      );
    }
  }

  void startTracking(
    dynamic tripId, {
    ActiveTripModel? activeTrip,
    int? childId,
  }) {
    _isMultiMode = false;
    _currentTripId = tripId;
    _stopTimer();

    // 🌟 تحديث أولي إذا لم توجد بيانات سابقة
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

    // 🌟 Polling صامت كل 5 ثوانٍ بدون إطلاق Loading جديد
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

    // 🌟 تحديث أولي إذا لم توجد بيانات سابقة
    if (state is! TripTrackingMultiLoaded &&
        state is! TripTrackingSingleLoaded) {
      emit(TripTrackingLoading());
    }

    _fetchMultiTrack(isSilent: false);

    // 🌟 Polling صامت كل 5 ثوانٍ بدون إطلاق Loading جديد
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
      // 🌟 في حالة الخطأ الاحتفاظ بآخر بيانات ناجحة وعدم مسح الخريطة
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
        emit(TripTrackingError(e.toString()));
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
      // 🌟 في حالة الخطأ الاحتفاظ بآخر بيانات ناجحة وعدم إخلاء الخريطة
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
        emit(TripTrackingError(e.toString()));
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
