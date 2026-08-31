import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import '../../data/repositories/driver_statistics_repository.dart';
import '../state/driver_statistics_state.dart';

class DriverStatisticsCubit extends Cubit<DriverStatisticsState> {
  final DriverStatisticsRepository _repository;

  int? currentMonth;
  int? currentYear;

  DriverStatisticsCubit(this._repository) : super(const DriverStatisticsInitial());

  Future<void> loadStatistics({int? month, int? year}) async {
    if (month != null) currentMonth = month;
    if (year != null) currentYear = year;

    emit(const DriverStatisticsLoading());

    try {
      final statistics = await _repository.getDriverStatistics(
        month: currentMonth,
        year: currentYear,
      );
      emit(DriverStatisticsSuccess(
        statistics: statistics,
        selectedMonth: currentMonth,
        selectedYear: currentYear,
      ));
    } catch (e) {
      final msg = e is ApiException ? e.message : 'تعذر تحميل إحصائياتك. يرجى المحاولة لاحقاً.';
      emit(DriverStatisticsError(msg));
    }
  }

  Future<void> refreshStatistics() async {
    try {
      final statistics = await _repository.getDriverStatistics(
        month: currentMonth,
        year: currentYear,
      );
      emit(DriverStatisticsSuccess(
        statistics: statistics,
        selectedMonth: currentMonth,
        selectedYear: currentYear,
      ));
    } catch (e) {
      if (state is! DriverStatisticsSuccess) {
        final msg = e is ApiException ? e.message : 'تعذر تحديث البيانات.';
        emit(DriverStatisticsError(msg));
      }
    }
  }

  void filterByDate({required int month, required int year}) {
    loadStatistics(month: month, year: year);
  }

  void resetFilter() {
    currentMonth = null;
    currentYear = null;
    loadStatistics();
  }
}
