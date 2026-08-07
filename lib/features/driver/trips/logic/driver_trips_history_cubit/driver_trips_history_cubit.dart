import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/features/driver/trips/data/models/driver_trip_history_model.dart';
import 'package:kids_transport/features/driver/trips/data/repositories/driver_trips_repository.dart';

part 'driver_trips_history_state.dart';

/// كوبيت سجل الرحلات وتفاصيل رحلة من السجل
class DriverTripsHistoryCubit extends Cubit<DriverTripsHistoryState> {
  final DriverTripsRepository _repository;

  DriverTripsHistoryCubit(this._repository) : super(DriverTripsHistoryInitial());

  Future<void> loadHistory() async {
    emit(DriverTripsHistoryLoading());
    try {
      final trips = await _repository.getHistory();
      emit(DriverTripsHistoryLoaded(trips));
    } catch (e) {
      emit(DriverTripsHistoryError('فشل تحميل سجل الرحلات: ${e.toString()}'));
    }
  }

  Future<void> loadHistoryDetails(int tripId) async {
    emit(DriverTripHistoryDetailsLoading());
    try {
      final details = await _repository.getHistoryDetails(tripId);
      emit(DriverTripHistoryDetailsLoaded(details));
    } catch (e) {
      emit(DriverTripHistoryDetailsError('فشل تحميل تفاصيل الرحلة: ${e.toString()}'));
    }
  }
}
