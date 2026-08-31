part of 'driver_absence_cubit.dart';

enum DriverAbsenceSubmitStatus { idle, submitting, success, error }

class DriverAbsenceState extends Equatable {
  final bool isLoadingTrips;
  final List<UpcomingAbsenceTripModel> upcomingTrips;
  final String? selectedDate;
  final Set<int> selectedTripIds;
  final String reason;
  final Set<DateTime> selectedDates; // للتوافقية
  final DriverAbsenceSubmitStatus submitStatus;
  final DriverRegisterAbsenceResponseModel? responseResult;
  final String? errorMessage;

  const DriverAbsenceState({
    this.isLoadingTrips = false,
    this.upcomingTrips = const [],
    this.selectedDate,
    this.selectedTripIds = const {},
    this.reason = '',
    this.selectedDates = const {},
    this.submitStatus = DriverAbsenceSubmitStatus.idle,
    this.responseResult,
    this.errorMessage,
  });

  /// الحصول على قائمة التواريخ الفريدة المتاحة في الرحلات القادمة
  List<String> get availableDates {
    final dates = upcomingTrips.map((e) => e.tripDate).where((d) => d.isNotEmpty).toSet().toList();
    dates.sort();
    return dates;
  }

  /// الحصول على الرحلات المتاحة في التاريخ المحدد حالياً
  List<UpcomingAbsenceTripModel> get tripsForSelectedDate {
    if (selectedDate == null || selectedDate!.isEmpty) return const [];
    return upcomingTrips.where((t) => t.tripDate == selectedDate).toList();
  }

  DriverAbsenceState copyWith({
    bool? isLoadingTrips,
    List<UpcomingAbsenceTripModel>? upcomingTrips,
    String? selectedDate,
    Set<int>? selectedTripIds,
    String? reason,
    Set<DateTime>? selectedDates,
    DriverAbsenceSubmitStatus? submitStatus,
    DriverRegisterAbsenceResponseModel? responseResult,
    String? errorMessage,
    bool clearError = false,
    bool clearSelectedDate = false,
  }) {
    return DriverAbsenceState(
      isLoadingTrips: isLoadingTrips ?? this.isLoadingTrips,
      upcomingTrips: upcomingTrips ?? this.upcomingTrips,
      selectedDate: clearSelectedDate ? null : (selectedDate ?? this.selectedDate),
      selectedTripIds: selectedTripIds ?? this.selectedTripIds,
      reason: reason ?? this.reason,
      selectedDates: selectedDates ?? this.selectedDates,
      submitStatus: submitStatus ?? this.submitStatus,
      responseResult: responseResult ?? this.responseResult,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        isLoadingTrips,
        upcomingTrips,
        selectedDate,
        selectedTripIds,
        reason,
        selectedDates,
        submitStatus,
        responseResult,
        errorMessage,
      ];
}
