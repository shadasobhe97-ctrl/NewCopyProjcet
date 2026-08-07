part of 'driver_absence_cubit.dart';

enum DriverAbsenceSubmitStatus { idle, submitting, success, error }

class DriverAbsenceState extends Equatable {
  final Set<DateTime> selectedDates;
  final DriverAbsenceSubmitStatus submitStatus;
  final String? errorMessage;

  const DriverAbsenceState({
    this.selectedDates = const {},
    this.submitStatus = DriverAbsenceSubmitStatus.idle,
    this.errorMessage,
  });

  DriverAbsenceState copyWith({
    Set<DateTime>? selectedDates,
    DriverAbsenceSubmitStatus? submitStatus,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DriverAbsenceState(
      selectedDates: selectedDates ?? this.selectedDates,
      submitStatus: submitStatus ?? this.submitStatus,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [selectedDates, submitStatus, errorMessage];
}
