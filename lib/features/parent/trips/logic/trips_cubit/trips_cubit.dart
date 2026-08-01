import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/trips_repository.dart';
import 'trips_state.dart';

class TripsCubit extends Cubit<TripsState> {
  final TripsRepository _repository;

  TripsCubit(this._repository) : super(TripsInitial());

  Future<void> fetchTripsOverview() async {
    emit(TripsLoading());
    try {
      final active = await _repository.getActiveTrips();
      final upcoming = await _repository.getUpcomingTrips();
      final history = await _repository.getTripHistory(1);

      emit(TripsLoaded(
        activeTrips: active,
        upcomingTrips: upcoming,
        historyTrips: history,
      ));
    } catch (e) {
      emit(TripsError(e.toString()));
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
