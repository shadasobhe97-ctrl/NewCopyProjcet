import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/network/api_exception.dart';
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
      final msg = (e is ApiException)
          ? e.message
          : e.toString().replaceAll('Exception:', '').trim();
      emit(ChildTripsError(msg));
    }
  }
}
