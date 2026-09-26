/// utility class for formatting date and time strings across the app.
abstract class AppDateFormatter {
  /// Formats date string into a clean Arabic/standard date format (e.g., "2026/09/26")
  static String formatDate(String? raw, {String fallback = ''}) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    final trimmed = raw.trim();

    final dt = DateTime.tryParse(trimmed);
    if (dt != null) {
      final localDt = dt.toLocal();
      final year = localDt.year;
      final month = localDt.month.toString().padLeft(2, '0');
      final day = localDt.day.toString().padLeft(2, '0');
      return '$year/$month/$day';
    }

    // If string contains date portion (yyyy-MM-dd)
    if (trimmed.contains('-') || trimmed.contains('/')) {
      final clean = trimmed.split('T').first.split(' ').first;
      return clean.replaceAll('-', '/');
    }

    return trimmed;
  }

  /// Formats time portion into clean 12-hour format with Arabic period (e.g., "04:34 م")
  static String formatTime(String? raw, {String fallback = ''}) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    final trimmed = raw.trim();

    final dt = DateTime.tryParse(trimmed);
    if (dt != null) {
      final localDt = dt.toLocal();
      final period = localDt.hour >= 12 ? 'م' : 'ص';
      final h12 = localDt.hour % 12 == 0 ? 12 : localDt.hour % 12;
      final minuteStr = localDt.minute.toString().padLeft(2, '0');
      final hourStr = h12.toString().padLeft(2, '0');
      return '$hourStr:$minuteStr $period';
    }

    // Try parsing raw string like "16:34:17" or "16:34"
    final timePart = trimmed.contains('T')
        ? trimmed.split('T').last
        : (trimmed.contains(' ') ? trimmed.split(' ').last : trimmed);
    final parts = timePart.split(':');
    if (parts.length >= 2) {
      final hour = int.tryParse(parts[0]);
      final min = int.tryParse(parts[1]);
      if (hour != null && min != null) {
        final period = hour >= 12 ? 'م' : 'ص';
        final h12 = hour % 12 == 0 ? 12 : hour % 12;
        final hourStr = h12.toString().padLeft(2, '0');
        final minStr = min.toString().padLeft(2, '0');
        return '$hourStr:$minStr $period';
      }
    }

    return trimmed;
  }

  /// Formats raw date-time into combined "YYYY/MM/DD • HH:MM AM/PM" format (e.g., "2026/09/26 • 04:34 م")
  static String formatDateTime(String? raw, {String fallback = ''}) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    final trimmed = raw.trim();

    final dt = DateTime.tryParse(trimmed);
    if (dt == null) {
      final date = formatDate(trimmed, fallback: fallback);
      final time = formatTime(trimmed, fallback: '');
      if (time.isNotEmpty && time != trimmed) {
        return '$date • $time';
      }
      return date;
    }

    final dateStr = formatDate(trimmed);
    final timeStr = formatTime(trimmed);

    // If time is 12:00 AM (midnight) with 00 minutes and raw didn't have time part, show only date
    if (!trimmed.contains('T') && !trimmed.contains(':')) {
      return dateStr;
    }

    return '$dateStr • $timeStr';
  }
}
