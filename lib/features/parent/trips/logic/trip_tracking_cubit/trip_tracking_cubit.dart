import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/trips_repository.dart';
import 'trip_tracking_state.dart';

class TripTrackingCubit extends Cubit<TripTrackingState> {
  final TripsRepository _repository;
  Timer? _timer;

  TripTrackingCubit(this._repository) : super(TripTrackingInitial());

  void startTracking(int tripId) {
    _timer?.cancel();
    emit(TripTrackingLoading());
    
    // Fetch immediately
    _fetchTrack(tripId);

    // Then fetch periodically every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchTrack(tripId);
    });
  }

  Future<void> _fetchTrack(int tripId) async {
    try {
      final trackData = await _repository.getTripTrack(tripId);
      emit(TripTrackingLoaded(trackData));
    } catch (e) {
      if (state is! TripTrackingLoaded) {
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
