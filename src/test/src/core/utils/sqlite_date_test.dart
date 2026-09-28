import 'package:flutter_test/flutter_test.dart';
import 'package:m3_pad/src/core/utils/sqlite_date.dart';

void main() {
  group('formatDateOnly', () {
    test('formats a DateTime as YYYY-MM-DD', () {
      expect(formatDateOnly(DateTime(2026, 9, 28)), '2026-09-28');
    });

    test('pads single-digit month and day with zeros', () {
      expect(formatDateOnly(DateTime(2026, 1, 5)), '2026-01-05');
    });

    test('ignores the time-of-day component', () {
      expect(formatDateOnly(DateTime(2026, 9, 28, 23, 59, 59)), '2026-09-28');
    });
  });

  group('parseDateOnly', () {
    test('parses a YYYY-MM-DD string back into a DateTime', () {
      final DateTime parsed = parseDateOnly('2026-09-28');
      expect(parsed.year, 2026);
      expect(parsed.month, 9);
      expect(parsed.day, 28);
    });

    test('round-trips with formatDateOnly', () {
      final DateTime original = DateTime(2026, 12, 31);
      expect(parseDateOnly(formatDateOnly(original)), original);
    });
  });
}
