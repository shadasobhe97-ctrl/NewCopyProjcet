import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/network/api_exception.dart';
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
      final msg = (e is ApiException)
          ? e.message
          : e.toString().replaceAll('Exception:', '').trim();
      emit(ActiveTripError(msg));
    }
  }

  Future<void> refresh() async {
    try {
      final activeTrips = await _repository.getActiveTrips();
      emit(ActiveTripLoaded(activeTrips));
    } catch (e) {
      final msg = (e is ApiException)
          ? e.message
          : e.toString().replaceAll('Exception:', '').trim();
      emit(ActiveTripError(msg));
    }
  }
}
