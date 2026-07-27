import 'package:equatable/equatable.dart';
import '../data/models/absence_model.dart';
import '../data/models/available_absence_dates_model.dart';

abstract class AbsenceState extends Equatable {
  const AbsenceState();

  @override
  List<Object?> get props => [];
}

class AbsenceInitial extends AbsenceState {}

// ─── تحميل الأيام المتاحة ───────────────────────────────────────────────
class AbsenceDatesLoading extends AbsenceState {}

class AbsenceDatesLoaded extends AbsenceState {
  final AvailableAbsenceDatesModel datesModel;
  final List<DateTime> selectedDates;
  final AbsenceType selectedType;

  const AbsenceDatesLoaded({
    required this.datesModel,
    this.selectedDates = const [],
    this.selectedType = AbsenceType.both,
  });

  AbsenceDatesLoaded copyWith({
    AvailableAbsenceDatesModel? datesModel,
    List<DateTime>? selectedDates,
    AbsenceType? selectedType,
  }) {
    return AbsenceDatesLoaded(
      datesModel: datesModel ?? this.datesModel,
      selectedDates: selectedDates ?? this.selectedDates,
      selectedType: selectedType ?? this.selectedType,
    );
  }

  @override
  List<Object?> get props => [datesModel, selectedDates, selectedType];
}

class AbsenceDatesError extends AbsenceState {
  final String message;
  const AbsenceDatesError(this.message);

  @override
  List<Object?> get props => [message];
}

// ─── تحميل قائمة الغيابات ────────────────────────────────────────────────
class AbsencesListLoading extends AbsenceState {}

class AbsencesListLoaded extends AbsenceState {
  final List<AbsenceModel> absences;

  const AbsencesListLoaded(this.absences);

  @override
  List<Object?> get props => [absences];
}

class AbsencesListError extends AbsenceState {
  final String message;
  const AbsencesListError(this.message);

  @override
  List<Object?> get props => [message];
}

// ─── حالة التحميل المتوازي (Dates + Absences معاً) ─────────────────────
class AbsenceFullLoading extends AbsenceState {}

class AbsenceFullLoaded extends AbsenceState {
  final AvailableAbsenceDatesModel datesModel;
  final List<AbsenceModel> absences;
  final List<DateTime> selectedDates;
  final AbsenceType selectedType;

  const AbsenceFullLoaded({
    required this.datesModel,
    required this.absences,
    this.selectedDates = const [],
    this.selectedType = AbsenceType.both,
  });

  AbsenceFullLoaded copyWith({
    AvailableAbsenceDatesModel? datesModel,
    List<AbsenceModel>? absences,
    List<DateTime>? selectedDates,
    AbsenceType? selectedType,
  }) {
    return AbsenceFullLoaded(
      datesModel: datesModel ?? this.datesModel,
      absences: absences ?? this.absences,
      selectedDates: selectedDates ?? this.selectedDates,
      selectedType: selectedType ?? this.selectedType,
    );
  }

  @override
  List<Object?> get props => [datesModel, absences, selectedDates, selectedType];
}

class AbsenceFullError extends AbsenceState {
  final String message;
  const AbsenceFullError(this.message);

  @override
  List<Object?> get props => [message];
}

// ─── إرسال / إلغاء ────────────────────────────────────────────────────
class AbsenceSubmitting extends AbsenceState {}

class AbsenceSuccess extends AbsenceState {
  final String message;
  const AbsenceSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AbsenceError extends AbsenceState {
  final String message;
  const AbsenceError(this.message);

  @override
  List<Object?> get props => [message];
}
