import 'package:flutter_test/flutter_test.dart';
import 'package:m3_pad/src/core/utils/currency_format.dart';

void main() {
  group('formatYen', () {
    test('formats a small amount without commas', () {
      expect(formatYen(400), '¥400');
    });

    test('inserts a comma for amounts of 4 or more digits', () {
      expect(formatYen(1200), '¥1,200');
    });

    test('inserts multiple commas for large amounts', () {
      expect(formatYen(1234567), '¥1,234,567');
    });

    test('formats zero without a comma', () {
      expect(formatYen(0), '¥0');
    });

    test('formats a negative amount with the sign before the yen mark', () {
      expect(formatYen(-1200), '¥-1,200');
    });
  });
}
