import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/features/driver/trips/data/repositories/driver_trips_repository.dart';

part 'driver_absence_state.dart';

/// كوبيت تسجيل غياب السائق (اختيار عدة تواريخ)
class DriverAbsenceCubit extends Cubit<DriverAbsenceState> {
  final DriverTripsRepository _repository;

  DriverAbsenceCubit(this._repository) : super(const DriverAbsenceState());

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

  Future<void> submit() async {
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
