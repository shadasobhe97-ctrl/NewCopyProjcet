import '../../data/models/driver_statistics_model.dart';

abstract class DriverStatisticsState {
  const DriverStatisticsState();
}

class DriverStatisticsInitial extends DriverStatisticsState {
  const DriverStatisticsInitial();
}

class DriverStatisticsLoading extends DriverStatisticsState {
  const DriverStatisticsLoading();
}

class DriverStatisticsSuccess extends DriverStatisticsState {
  final DriverStatisticsModel statistics;
  final int? selectedMonth;
  final int? selectedYear;

  const DriverStatisticsSuccess({
    required this.statistics,
    this.selectedMonth,
    this.selectedYear,
  });

  DriverStatisticsSuccess copyWith({
    DriverStatisticsModel? statistics,
    int? selectedMonth,
    int? selectedYear,
  }) {
    return DriverStatisticsSuccess(
      statistics: statistics ?? this.statistics,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedYear: selectedYear ?? this.selectedYear,
    );
  }
}

class DriverStatisticsError extends DriverStatisticsState {
  final String message;

  const DriverStatisticsError(this.message);
}
