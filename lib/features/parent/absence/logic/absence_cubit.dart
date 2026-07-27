import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/absence_model.dart';
import '../data/models/available_absence_dates_model.dart';
import '../data/repositories/absence_repository.dart';
import 'absence_state.dart';

class AbsenceCubit extends Cubit<AbsenceState> {
  final AbsenceRepository _repository;

  AbsenceCubit(this._repository) : super(AbsenceInitial());

  // ─── تحميل متوازي: الأيام المتاحة + الغيابات المجدولة معاً ───────────
  Future<void> loadAbsenceData(int childId) async {
    emit(AbsenceFullLoading());
    try {
      final results = await Future.wait([
        _repository.getAvailableAbsenceDates(childId),
        _repository.getAbsences(childId),
      ]);

      final datesModel = results[0] as AvailableAbsenceDatesModel;
      final absences = results[1] as List<AbsenceModel>;

      emit(
        AbsenceFullLoaded(
          datesModel: datesModel,
          absences: absences,
          selectedDates: const [],
          selectedType: AbsenceType.both,
        ),
      );
    } catch (e) {
      emit(AbsenceFullError(_parseError(e)));
    }
  }

  // ─── تحديث الأيام المختارة ─────────────────────────────────────────────
  void toggleDate(DateTime date) {
    final current = state;
    if (current is! AbsenceFullLoaded) return;

    // تأكد أن اليوم متاح وليس غائباً مسبقاً
    if (!current.datesModel.isAvailable(date)) return;
    if (current.datesModel.isAlreadyAbsent(date)) return;

    final d = DateTime(date.year, date.month, date.day);
    final selected = List<DateTime>.from(current.selectedDates);

    final idx = selected.indexWhere(
      (s) => DateTime(s.year, s.month, s.day) == d,
    );

    if (idx >= 0) {
      selected.removeAt(idx);
    } else {
      selected.add(d);
    }

    emit(current.copyWith(selectedDates: selected));
  }

  // ─── تغيير نوع الغياب ──────────────────────────────────────────────────
  void changeAbsenceType(AbsenceType type) {
    final current = state;
    if (current is! AbsenceFullLoaded) return;
    emit(current.copyWith(selectedType: type));
  }

  // ─── تسجيل الغياب ─────────────────────────────────────────────────────
  Future<void> setAbsence(int childId) async {
    final current = state;
    if (current is! AbsenceFullLoaded) return;
    if (current.selectedDates.isEmpty) return;

    final snapshot = current;
    emit(AbsenceSubmitting());
    try {
      final dates = snapshot.selectedDates
          .map((d) => d.toIso8601String().split('T').first)
          .toList();

      await _repository.setAbsence(
        childId: childId,
        dates: dates,
        absenceType: snapshot.selectedType,
      );

      emit(const AbsenceSuccess('تم تسجيل الغياب بنجاح ✓'));

      // إعادة تحميل البيانات بعد النجاح
      await loadAbsenceData(childId);
    } catch (e) {
      emit(AbsenceError(_parseError(e)));
      // استعادة الحالة السابقة
      emit(snapshot.copyWith(selectedDates: const []));
    }
  }

  // ─── إلغاء غياب ───────────────────────────────────────────────────────
  Future<void> cancelAbsence({
    required int childId,
    required String date,
    required AbsenceType absenceType,
  }) async {
    final current = state;
    if (current is! AbsenceFullLoaded) return;

    final snapshot = current;
    emit(AbsenceSubmitting());
    try {
      await _repository.cancelAbsence(
        childId: childId,
        date: date,
        absenceType: absenceType,
      );

      emit(const AbsenceSuccess('تم إلغاء الغياب بنجاح'));

      // إعادة تحميل البيانات بعد الإلغاء
      await loadAbsenceData(childId);
    } catch (e) {
      emit(AbsenceError(_parseError(e)));
      emit(snapshot);
    }
  }

  // ─── معالجة الأخطاء ────────────────────────────────────────────────────
  String _parseError(dynamic e) {
    if (e is DioException) {
      if (e.response != null) {
        final code = e.response!.statusCode;
        final data = e.response!.data;
        if (data is Map && data['message'] != null) {
          return data['message'].toString();
        }
        switch (code) {
          case 401:
            return 'غير مصرح لك بالوصول. يرجى تسجيل الدخول مجدداً.';
          case 403:
            return 'ليس لديك صلاحية لإجراء هذه العملية.';
          case 404:
            return 'لم يتم العثور على البيانات المطلوبة.';
          case 422:
            return 'البيانات المرسلة غير صالحة. يرجى مراجعة الحقول.';
          case 500:
            return 'حدث خطأ في الخادم. يرجى المحاولة لاحقاً.';
          default:
            return 'خطأ في الاتصال بالخادم ($code)';
        }
      }
      return 'فشل الاتصال بالإنترنت. يرجى التحقق من الشبكة.';
    }
    return e.toString().replaceAll('Exception:', '').trim();
  }
}
