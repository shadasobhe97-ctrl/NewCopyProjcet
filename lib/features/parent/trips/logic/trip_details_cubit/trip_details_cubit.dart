import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/trips_repository.dart';
import 'trip_details_state.dart';

class TripDetailsCubit extends Cubit<TripDetailsState> {
  final TripsRepository _repository;

  TripDetailsCubit(this._repository) : super(TripDetailsInitial());

  Future<void> loadTripDetails(dynamic tripId) async {
    emit(TripDetailsLoading());
    try {
      final details = await _repository.getTripDetails(tripId);
      emit(TripDetailsLoaded(details));
    } catch (e) {
      emit(TripDetailsError(e.toString()));
    }
  }

  Future<void> fetchTripDetails(dynamic tripId) => loadTripDetails(tripId);
}
