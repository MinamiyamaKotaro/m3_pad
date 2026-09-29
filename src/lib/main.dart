import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import 'src/core/database/app_database.dart';
import 'src/core/database/database_provider.dart';
import 'src/features/voucher/data/seed/seed_sushi_template.dart';
import 'src/features/voucher/domain/entities/sheet_template.dart';
import 'src/features/voucher/presentation/pages/voucher_sheet_page.dart';

/// アプリケーションのエントリーポイント。
///
/// SQLiteデータベースを開いてから[ProviderScope]でラップしたアプリを起動
/// する。
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Database database = await const AppDatabase().open();
  runApp(
    ProviderScope(
      // Overrideはflutter_riverpodからpublicに公開されていないため、
      // 型引数を明示できない。
      // ignore: always_specify_types
      overrides: [databaseProvider.overrideWithValue(database)],
      child: const M3PadApp(),
    ),
  );
}

/// 伝票デジタル化アプリのルートウィジェット。
class M3PadApp extends ConsumerWidget {
  /// [M3PadApp] を生成する。
  const M3PadApp({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) => MaterialApp(
        title: '伝票デジタル化アプリ',
        theme: ThemeData(
          // docs/ui/wireframeの配色（style.cssの--color-*）に合わせる。
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF050505),
            onPrimary: Color(0xFFFFF7EF),
            onSurface: Color(0xFF2B2621),
            surfaceContainerHighest: Color(0xFFFAF8F3),
            onSurfaceVariant: Color(0xFF746B5C),
            outline: Color(0xFFD8D2C4),
            outlineVariant: Color(0xFFB9B09A),
            error: Color(0xFF8A2A1F),
            errorContainer: Color(0xFFFBE8E6),
          ),
          scaffoldBackgroundColor: const Color(0xFFF4F1EA),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF050505),
            foregroundColor: Color(0xFFFFF7EF),
          ),
          useMaterial3: true,
        ),
        home: Consumer(
          builder: (
            final BuildContext context,
            final WidgetRef ref,
            final Widget? child,
          ) =>
              FutureBuilder<SheetTemplate>(
            future: ensureSushiTemplate(ref),
            builder: (
              final BuildContext context,
              final AsyncSnapshot<SheetTemplate> snapshot,
            ) {
              if (!snapshot.hasData) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              return VoucherSheetPage(
                sheetTemplateId: snapshot.data!.sheetTemplateId,
                businessDate: DateTime.now(),
              );
            },
          ),
        ),
      );
}
