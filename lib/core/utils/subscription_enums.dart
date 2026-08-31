/// توحيد قيم عقد الـ API الخاصة بالاشتراك وتسمياتها بالعربية.
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

  // ── ترجمة حالة الاشتراك / الطلب ──
  static String statusLabel(String? rawStatus, {String? fallbackLabel}) {
    if (fallbackLabel != null && fallbackLabel.trim().isNotEmpty) {
      final translatedFallback = _translateStatusString(fallbackLabel.trim());
      if (translatedFallback != null) return translatedFallback;
      if (RegExp(r'[\u0600-\u06FF]').hasMatch(fallbackLabel)) {
        return fallbackLabel.trim();
      }
    }

    final status = (rawStatus ?? '').trim().toLowerCase();
    final translated = _translateStatusString(status);
    return translated ?? 'غير محدد';
  }

  static String? _translateStatusString(String str) {
    final lower = str.toLowerCase();
    if (lower.contains('active')) return 'نشط';
    if (lower.contains('accepted') || lower.contains('approved')) return 'مقبول';
    if (lower.contains('pending_start')) return 'بانتظار البدء';
    if (lower.contains('pending') || lower.contains('waiting')) return 'قيد الانتظار';
    if (lower.contains('completed') || lower.contains('finished')) return 'مكتمل';
    if (lower.contains('cancelled') || lower.contains('canceled')) return 'ملغي';
    if (lower.contains('rejected')) return 'مرفوض';
    if (lower.contains('hold') || lower.contains('suspended')) return 'معلق مؤقتاً';
    return null;
  }

  // ── جنس الطفل بالعربية ──
  static String genderLabel(String? raw) {
    if (raw == null) return 'غير محدد';
    final lower = raw.trim().toLowerCase();
    if (lower == 'male' || lower == 'm' || lower == 'boy' || lower == 'man' || lower == 'ذكر') {
      return 'ذكر';
    }
    if (lower == 'female' || lower == 'f' || lower == 'girl' || lower == 'woman' || lower == 'أنثى') {
      return 'أنثى';
    }
    return 'غير محدد';
  }

  // ── تنظيف العناوين والمواقع من الكلمات الإنجليزية والـ Placeholders ──
  static String cleanAddress(String? raw, {String fallback = 'غير محدد'}) {
    if (raw == null) return fallback;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return fallback;
    final lower = trimmed.toLowerCase();
    if (lower == 'null' ||
        lower == 'n/a' ||
        lower == 'none' ||
        lower == 'undefined' ||
        lower == 'عنوان غير متوفر' ||
        lower == 'غير متوفر' ||
        lower == 'غير محدد') {
      return fallback;
    }
    return trimmed;
  }
}
