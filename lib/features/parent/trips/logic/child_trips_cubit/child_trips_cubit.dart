import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/trips_repository.dart';
import 'child_trips_state.dart';

class ChildTripsCubit extends Cubit<ChildTripsState> {
  final TripsRepository _repository;

  ChildTripsCubit(this._repository) : super(ChildTripsInitial());

  Future<void> loadChildTrips(dynamic childId) async {
    emit(ChildTripsLoading());
    try {
      final childTrips = await _repository.getChildTrips(childId);
      emit(ChildTripsLoaded(childTrips));
    } catch (e) {
      emit(ChildTripsError(e.toString()));
    }
  }
}
