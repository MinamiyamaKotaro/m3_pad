import 'package:flutter_test/flutter_test.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/enums/enums.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/header.dart';
import 'package:m3_pad/src/features/voucher/domain/usecases/header_grouping.dart';

void main() {
  final DateTime now = DateTime(2026, 10, 3);

  Header header(final String columnId, {final bool isPriced = true}) => Header(
        columnId: columnId,
        sheetTemplateId: 'template-1',
        typeId: 1,
        name: columnId,
        displayOrder: 0,
        isPriced: isPriced,
        status: RecordStatus.active,
        createdAt: now,
        updatedAt: now,
      );

  List<List<String>> ids(final List<List<Header>> groups) => groups
      .map(
        (final List<Header> group) =>
            group.map((final Header h) => h.columnId).toList(),
      )
      .toList();

  group('groupHeadersByPrice', () {
    test('groups same-price columns even when they are not adjacent', () {
      final List<List<Header>> groups = groupHeadersByPrice(
        <Header>[header('a'), header('b'), header('c')],
        <String, int>{'a': 500, 'b': 600, 'c': 500},
      );
      expect(ids(groups), <List<String>>[
        <String>['a', 'c'],
        <String>['b'],
      ]);
    });

    test('keeps a column without a price as its own group in place', () {
      final List<List<Header>> groups = groupHeadersByPrice(
        <Header>[header('a'), header('b'), header('c')],
        <String, int>{'a': 500, 'c': 500},
      );
      expect(ids(groups), <List<String>>[
        <String>['a', 'c'],
        <String>['b'],
      ]);
    });

    test('places non-priced columns after all priced columns', () {
      final List<List<Header>> groups = groupHeadersByPrice(
        <Header>[header('memo', isPriced: false), header('a'), header('b')],
        <String, int>{'a': 500, 'b': 500},
      );
      expect(ids(groups), <List<String>>[
        <String>['a', 'b'],
        <String>['memo'],
      ]);
    });

    test('returns an empty list for no headers', () {
      expect(groupHeadersByPrice(<Header>[], <String, int>{}), isEmpty);
    });
  });
}
