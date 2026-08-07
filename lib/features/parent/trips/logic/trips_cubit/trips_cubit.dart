import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import '../../data/repositories/trips_repository.dart';
import '../../data/models/active_trip_model.dart';
import '../../data/models/upcoming_trip_model.dart';
import '../../data/models/trip_history_model.dart';
import 'trips_state.dart';

class TripsCubit extends Cubit<TripsState> {
  final TripsRepository _repository;

  TripsCubit(this._repository) : super(TripsInitial());

  Future<void> fetchTripsOverview() async {
    emit(TripsLoading());
    
    List<ActiveTripModel> active = [];
    String? activeErr;
    try {
      active = await _repository.getActiveTrips();
    } catch (e) {
      activeErr = (e is ApiException)
          ? e.message
          : e.toString().replaceAll('Exception:', '').trim();
    }

    List<UpcomingTripModel> upcoming = [];
    String? upcomingErr;
    try {
      upcoming = await _repository.getUpcomingTrips();
    } catch (e) {
      upcomingErr = (e is ApiException)
          ? e.message
          : e.toString().replaceAll('Exception:', '').trim();
    }

    List<TripHistoryModel> history = [];
    String? historyErr;
    try {
      final historyRes = await _repository.getTripHistory(page: 1, perPage: 15);
      history = historyRes.data;
    } catch (e) {
      historyErr = (e is ApiException)
          ? e.message
          : e.toString().replaceAll('Exception:', '').trim();
    }

    // If all three calls failed, then emit TripsError
    if (activeErr != null && upcomingErr != null && historyErr != null) {
      emit(TripsError(activeErr));
    } else {
      emit(TripsLoaded(
        activeTrips: active,
        upcomingTrips: upcoming,
        historyTrips: history,
        activeError: activeErr,
        upcomingError: upcomingErr,
        historyError: historyErr,
      ));
    }
  }

  void filterByChild(int? childId, String childName) {
    if (state is TripsLoaded) {
      final currentState = state as TripsLoaded;
      if (childId == null) {
        emit(currentState.copyWith(clearChildFilter: true));
      } else {
        emit(currentState.copyWith(
          selectedChildId: childId,
          selectedChildName: childName,
        ));
      }
    }
  }
}
