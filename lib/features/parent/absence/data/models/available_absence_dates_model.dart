/// نموذج الأيام المتاحة للغياب
class AvailableAbsenceDatesModel {
  /// الأيام القادمة التي يمكن للطفل التغيب فيها
  final List<DateTime> availableDates;

  /// الأيام التي تم تسجيل غياب فيها مسبقاً
  final List<DateTime> alreadyAbsentDates;

  const AvailableAbsenceDatesModel({
    required this.availableDates,
    required this.alreadyAbsentDates,
  });

  bool get isEmpty =>
      availableDates.isEmpty && alreadyAbsentDates.isEmpty;

  factory AvailableAbsenceDatesModel.fromJson(Map<String, dynamic> json) {
    List<DateTime> parseDates(dynamic raw) {
      if (raw is List) {
        return raw
            .map((e) => DateTime.tryParse(e.toString()))
            .whereType<DateTime>()
            .toList();
      }
      return [];
    }

    // يدعم مفاتيح مختلفة من الباك إند
    final available = parseDates(
      json['available_dates'] ??
          json['available'] ??
          json['dates'] ??
          [],
    );

    final alreadyAbsent = parseDates(
      json['already_absent_dates'] ??
          json['already_absent'] ??
          json['absent_dates'] ??
          [],
    );

    return AvailableAbsenceDatesModel(
      availableDates: available,
      alreadyAbsentDates: alreadyAbsent,
    );
  }

  /// هل اليوم متاح للاختيار؟
  bool isAvailable(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return availableDates.any(
      (a) => DateTime(a.year, a.month, a.day) == d,
    );
  }

  /// هل اليوم مسجّل كغياب مسبقاً؟
  bool isAlreadyAbsent(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return alreadyAbsentDates.any(
      (a) => DateTime(a.year, a.month, a.day) == d,
    );
  }
}
