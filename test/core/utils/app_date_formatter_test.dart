import 'package:flutter_test/flutter_test.dart';
import 'package:kids_transport/core/utils/app_date_formatter.dart';

void main() {
  group('AppDateFormatter Unit Tests', () {
    test('formatDate should format ISO 8601 string to YYYY/MM/DD', () {
      final formatted = AppDateFormatter.formatDate('2026-09-26T16:34:17+02:00');
      expect(formatted, contains('2026/09/26'));
    });

    test('formatTime should format 24h ISO time to 12h Arabic time', () {
      final formatted1 = AppDateFormatter.formatTime('2026-09-26T16:34:17+02:00');
      expect(formatted1, contains('م'));

      final formatted2 = AppDateFormatter.formatTime('2026-09-26T09:15:00+02:00');
      expect(formatted2, contains('ص'));
    });

    test('formatDateTime should combine date and time nicely', () {
      final formatted = AppDateFormatter.formatDateTime('2026-09-26T16:34:17+02:00');
      expect(formatted, contains('2026/09/26'));
      expect(formatted, contains('•'));
      expect(formatted, contains('م'));
    });

    test('formatDate handles null/empty gracefully', () {
      expect(AppDateFormatter.formatDate(null), equals(''));
      expect(AppDateFormatter.formatDate(''), equals(''));
      expect(AppDateFormatter.formatDate(null, fallback: 'N/A'), equals('N/A'));
    });
  });
}
