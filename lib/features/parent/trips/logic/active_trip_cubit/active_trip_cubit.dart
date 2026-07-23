import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/trips_repository.dart';
import 'active_trip_state.dart';

class ActiveTripCubit extends Cubit<ActiveTripState> {
  final TripsRepository _repository;

  ActiveTripCubit(this._repository) : super(ActiveTripInitial());

  Future<void> loadActiveTrips() async {
    emit(ActiveTripLoading());
    try {
      final activeTrips = await _repository.getActiveTrips();
      emit(ActiveTripLoaded(activeTrips));
    } catch (e) {
      emit(ActiveTripError(e.toString()));
    }
  }

  Future<void> refresh() async {
    try {
      final activeTrips = await _repository.getActiveTrips();
      emit(ActiveTripLoaded(activeTrips));
    } catch (e) {
      emit(ActiveTripError(e.toString()));
    }
  }
}
