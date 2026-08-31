import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/features/driver/trips/data/models/driver_absence_model.dart';
import 'package:kids_transport/features/driver/trips/data/repositories/driver_trips_repository.dart';

part 'driver_absence_state.dart';

/// كوبيت تسجيل غياب السائق (جلب الرحلات القادمة، اختيار الرحلات، وإرسال السبب والاعتماد الفوري approved)
class DriverAbsenceCubit extends Cubit<DriverAbsenceState> {
  final DriverTripsRepository _repository;

  DriverAbsenceCubit(this._repository) : super(const DriverAbsenceState());

  /// جلب الرحلات القادمة للسائق من /api/driver/trips/upcoming-for-absence
  Future<void> loadUpcomingTrips() async {
    emit(state.copyWith(isLoadingTrips: true, clearError: true));
    try {
      final trips = await _repository.getUpcomingTripsForAbsence();
      final availableDates = trips.map((e) => e.tripDate).where((d) => d.isNotEmpty).toSet().toList();
      availableDates.sort();

      final initialDate = availableDates.isNotEmpty ? availableDates.first : state.selectedDate;

      emit(state.copyWith(
        isLoadingTrips: false,
        upcomingTrips: trips,
        selectedDate: initialDate,
      ));
    } catch (e) {
      final message = e is ApiException ? e.message : 'تعذر جلب الرحلات القادمة للغياب.';
      emit(state.copyWith(
        isLoadingTrips: false,
        errorMessage: message,
      ));
    }
  }

  /// اختيار تاريخ الغياب
  void selectDate(String date) {
    emit(state.copyWith(
      selectedDate: date,
      selectedTripIds: const {},
      clearError: true,
    ));
  }

  /// تحديد / إلغاء تحديد رحلة ضمن التاريخ المختار
  void toggleTripSelection(int tripId) {
    final updated = Set<int>.from(state.selectedTripIds);
    if (updated.contains(tripId)) {
      updated.remove(tripId);
    } else {
      updated.add(tripId);
    }
    emit(state.copyWith(selectedTripIds: updated, clearError: true));
  }

  /// تحديث سبب الغياب
  void updateReason(String reason) {
    emit(state.copyWith(reason: reason, clearError: true));
  }

  /// إرسال طلب الغياب عن الرحلات المحددة والتاريخ والسبب (POST /api/driver/trips/register-absence)
  Future<void> submitAbsenceWithTrips() async {
    if (state.selectedDate == null || state.selectedDate!.isEmpty) {
      emit(state.copyWith(
        submitStatus: DriverAbsenceSubmitStatus.error,
        errorMessage: 'يرجى اختيار تاريخ الغياب أولاً.',
      ));
      return;
    }

    if (state.selectedTripIds.isEmpty) {
      emit(state.copyWith(
        submitStatus: DriverAbsenceSubmitStatus.error,
        errorMessage: 'يرجى تحديد رحلة واحدة على الأقل للغياب عنها.',
      ));
      return;
    }

    if (state.reason.trim().isEmpty) {
      emit(state.copyWith(
        submitStatus: DriverAbsenceSubmitStatus.error,
        errorMessage: 'يرجى إدخال سبب الغياب.',
      ));
      return;
    }

    emit(state.copyWith(submitStatus: DriverAbsenceSubmitStatus.submitting, clearError: true));

    try {
      final request = DriverRegisterAbsenceRequestModel(
        date: state.selectedDate!,
        tripIds: state.selectedTripIds.toList(),
        reason: state.reason.trim(),
      );

      final result = await _repository.registerAbsenceWithTrips(request);

      emit(state.copyWith(
        submitStatus: DriverAbsenceSubmitStatus.success,
        responseResult: result,
      ));
    } catch (e) {
      final message = e is ApiException ? e.message : 'فشل تسجيل الغياب: ${e.toString()}';
      emit(state.copyWith(
        submitStatus: DriverAbsenceSubmitStatus.error,
        errorMessage: message,
      ));
    }
  }

  /// التوافقية القديمة
  void toggleDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final updated = Set<DateTime>.from(state.selectedDates);
    if (updated.contains(normalized)) {
      updated.remove(normalized);
    } else {
      updated.add(normalized);
    }
    emit(state.copyWith(selectedDates: updated, clearError: true));
  }

  /// التوافقية القديمة
  Future<void> submit() async {
    if (state.selectedTripIds.isNotEmpty && state.selectedDate != null) {
      await submitAbsenceWithTrips();
      return;
    }

    if (state.selectedDates.isEmpty) return;
    emit(state.copyWith(submitStatus: DriverAbsenceSubmitStatus.submitting, clearError: true));
    try {
      final dates = state.selectedDates.map(_formatDate).toList();
      await _repository.registerAbsence(dates);
      emit(state.copyWith(submitStatus: DriverAbsenceSubmitStatus.success));
    } catch (e) {
      final message = e is ApiException ? e.message : 'فشل تسجيل الغياب: ${e.toString()}';
      emit(state.copyWith(submitStatus: DriverAbsenceSubmitStatus.error, errorMessage: message));
    }
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
