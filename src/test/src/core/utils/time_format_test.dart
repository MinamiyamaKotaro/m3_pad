import 'package:flutter_test/flutter_test.dart';
import 'package:m3_pad/src/core/utils/time_format.dart';

void main() {
  group('formatHHmm', () {
    test('zero-pads single-digit hours and minutes', () {
      expect(formatHHmm(DateTime(2026, 10, 3, 9, 5)), '09:05');
    });

    test('formats afternoon hours in 24-hour notation', () {
      expect(formatHHmm(DateTime(2026, 10, 3, 18, 30)), '18:30');
    });
  });

  group('normalizeHHmm', () {
    test('keeps a value already in HH:mm format', () {
      expect(normalizeHHmm('18:30'), '18:30');
    });

    test('zero-pads a single-digit hour', () {
      expect(normalizeHHmm('9:05'), '09:05');
    });

    test('accepts a value without a colon', () {
      expect(normalizeHHmm('1830'), '18:30');
      expect(normalizeHHmm('930'), '09:30');
    });

    test('converts full-width digits and colon to half-width', () {
      expect(normalizeHHmm('１８：３０'), '18:30');
    });

    test('trims surrounding whitespace', () {
      expect(normalizeHHmm(' 18:30 '), '18:30');
    });

    test('returns null for an out-of-range hour or minute', () {
      expect(normalizeHHmm('24:00'), isNull);
      expect(normalizeHHmm('18:60'), isNull);
    });

    test('returns null for a value that is not a time', () {
      expect(normalizeHHmm(''), isNull);
      expect(normalizeHHmm('abc'), isNull);
      expect(normalizeHHmm('18:3'), isNull);
    });
  });
}
