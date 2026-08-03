import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import '../../data/repositories/trips_repository.dart';
import 'upcoming_trips_state.dart';

class UpcomingTripsCubit extends Cubit<UpcomingTripsState> {
  final TripsRepository _repository;

  UpcomingTripsCubit(this._repository) : super(UpcomingTripsInitial());

  Future<void> loadUpcomingTrips() async {
    emit(UpcomingTripsLoading());
    try {
      final upcomingTrips = await _repository.getUpcomingTrips();
      emit(UpcomingTripsLoaded(upcomingTrips));
    } catch (e) {
      final msg = (e is ApiException)
          ? e.message
          : e.toString().replaceAll('Exception:', '').trim();
      emit(UpcomingTripsError(msg));
    }
  }
}
