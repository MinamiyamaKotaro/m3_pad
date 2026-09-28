import 'package:flutter_test/flutter_test.dart';
import 'package:m3_pad/src/core/utils/id_generator.dart';

void main() {
  group('IdGenerator', () {
    const IdGenerator idGenerator = IdGenerator();

    test('generates a 26-character ULID string', () {
      expect(idGenerator.generate().length, 26);
    });

    test('generates a different id on each call', () {
      expect(idGenerator.generate(), isNot(idGenerator.generate()));
    });
  });
}
