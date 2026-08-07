import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/features/driver/trips/data/models/driver_trip_details_model.dart';
import 'package:kids_transport/features/driver/trips/data/models/driver_trip_model.dart';
import 'package:kids_transport/features/driver/trips/data/repositories/driver_trips_repository.dart';

part 'driver_trips_state.dart';

/// كوبيت رحلات اليوم + تفاصيل الرحلة + بدء الرحلة
class DriverTripsCubit extends Cubit<DriverTripsState> {
  final DriverTripsRepository _repository;

  DriverTripsCubit(this._repository) : super(DriverTripsInitial());

  Future<void> loadTripsToday() async {
    emit(DriverTripsLoading());
    try {
      final trips = await _repository.getTripsToday();
      emit(DriverTripsLoaded(trips));
    } catch (e) {
      emit(DriverTripsError('فشل تحميل رحلات اليوم: ${e.toString()}'));
    }
  }

  Future<void> refresh() => loadTripsToday();

  Future<void> loadTripDetails(int tripId) async {
    emit(DriverTripDetailsLoading());
    try {
      final details = await _repository.getTripDetails(tripId);
      emit(DriverTripDetailsLoaded(details));
    } catch (e) {
      emit(DriverTripDetailsError('فشل تحميل تفاصيل الرحلة: ${e.toString()}'));
    }
  }

  /// يبدأ الرحلة ويُرجع رقمها عند النجاح، أو يرمي الاستثناء عند الفشل
  /// (لا يُغيّر حالة الكوبيت لتفادي فقدان قائمة رحلات اليوم المعروضة).
  Future<int> startTrip(int tripId, {double? latitude, double? longitude}) async {
    final result = await _repository.startTrip(
      tripId,
      latitude: latitude,
      longitude: longitude,
    );
    return result.tripId;
  }
}
