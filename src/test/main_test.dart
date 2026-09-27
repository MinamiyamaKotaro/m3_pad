import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m3_pad/main.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/enums/enums.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/sheet_template.dart';
import 'package:m3_pad/src/features/voucher/domain/repositories/sheet_template_repository.dart';
import 'package:m3_pad/src/features/voucher/presentation/controllers/voucher_providers.dart';

/// テンプレートが既に存在する状態を模した[SheetTemplateRepository]。
///
/// main.dartの起動シーケンス（`ensureSushiTemplate`呼び出し）を、実DBを
/// 使わずに検証するためのテスト用フェイク。
class _ExistingTemplateRepository implements SheetTemplateRepository {
  @override
  Future<List<SheetTemplate>> findAllActive() async => <SheetTemplate>[
        SheetTemplate(
          sheetTemplateId: 'template-1',
          name: '寿',
          status: RecordStatus.active,
          createdAt: DateTime(2026, 9, 28),
          updatedAt: DateTime(2026, 9, 28),
        ),
      ];

  @override
  Future<SheetTemplate> findById(final String sheetTemplateId) =>
      throw UnimplementedError();

  @override
  Future<void> insert(final SheetTemplate template) =>
      throw UnimplementedError();
}

void main() {
  group('M3PadApp', () {
    testWidgets('shows a loading indicator while the template loads', (
      final WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          // Overrideはflutter_riverpodからpublicに公開されていないため、
          // 型引数を明示できない。
          // ignore: always_specify_types
          overrides: [
            sheetTemplateRepositoryProvider.overrideWithValue(
              _ExistingTemplateRepository(),
            ),
          ],
          child: const M3PadApp(),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('configures the MaterialApp title', (
      final WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          // Overrideはflutter_riverpodからpublicに公開されていないため、
          // 型引数を明示できない。
          // ignore: always_specify_types
          overrides: [
            sheetTemplateRepositoryProvider.overrideWithValue(
              _ExistingTemplateRepository(),
            ),
          ],
          child: const M3PadApp(),
        ),
      );
      await tester.pump();

      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.title, '伝票デジタル化アプリ');
    });
  });
}
