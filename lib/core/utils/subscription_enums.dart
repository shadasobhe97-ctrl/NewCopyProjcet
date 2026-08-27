/// توحيد قيم عقد الـ API الخاصة بالاشتراك وتسمياتها بالعربية.
///
/// عقد الباك إند:
///  - subscription_type : single_day | multi_day   (لا يوجد شهري/أسبوعي)
///  - trip_direction    : go | return | both
///  - timing            : MORNING | EVENING | BOTH
class SubscriptionEnums {
  const SubscriptionEnums._();

  // ── نوع الاشتراك ──
  static const String singleDay = 'single_day';
  static const String multiDay = 'multi_day';

  /// يحوّل أي قيمة قديمة (daily / days / weekly / monthly ...) إلى قيمة العقد.
  static String normalizeType(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case 'single_day':
      case 'single-day':
      case 'singleday':
      case 'daily':
      case 'days':
      case 'day':
      case 'one_day':
        return singleDay;
      default:
        return multiDay;
    }
  }

  static String typeLabel(String? raw) =>
      normalizeType(raw) == singleDay ? 'يوم واحد' : 'عدة أيام';

  // ── اتجاه الرحلة ──
  static const String go = 'go';
  static const String returnTrip = 'return';
  static const String both = 'both';

  /// يحوّل أي قيمة قديمة (two_way / one_way_evening ...) إلى قيمة العقد.
  static String normalizeDirection(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case 'go':
      case 'one_way':
      case 'one_way_go':
      case 'one_way_morning':
      case 'one_way_to_school':
      case 'to_school':
      case 'morning':
        return go;
      case 'return':
      case 'one_way_return':
      case 'one_way_evening':
      case 'one_way_to_home':
      case 'to_home':
      case 'evening':
        return returnTrip;
      default:
        return both;
    }
  }

  static String directionLabel(String? raw) {
    switch (normalizeDirection(raw)) {
      case go:
        return 'ذهاب فقط';
      case returnTrip:
        return 'عودة فقط';
      default:
        return 'ذهاب وعودة';
    }
  }

  // ── الفترة ──
  static const String morning = 'MORNING';
  static const String evening = 'EVENING';
  static const String bothTimings = 'BOTH';

  static String normalizeTiming(String? raw) {
    switch ((raw ?? '').trim().toUpperCase()) {
      case 'MORNING':
      case 'AM':
        return morning;
      case 'EVENING':
      case 'AFTERNOON':
      case 'PM':
        return evening;
      default:
        return bothTimings;
    }
  }

  static String timingLabel(String? raw) {
    switch (normalizeTiming(raw)) {
      case morning:
        return 'صباحاً';
      case evening:
        return 'مساءً';
      default:
        return 'صباحاً ومساءً';
    }
  }
}
