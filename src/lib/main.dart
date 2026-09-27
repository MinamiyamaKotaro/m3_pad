import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// アプリケーションのエントリーポイント。
void main() {
  runApp(const ProviderScope(child: M3PadApp()));
}

/// 伝票デジタル化アプリのルートウィジェット。
///
/// 実際の画面（`ENT_001_VOUCHER`）は `docs/design` の設計に基づき今後実装する。
class M3PadApp extends StatelessWidget {
  /// [M3PadApp] を生成する。
  const M3PadApp({super.key});

  @override
  Widget build(final BuildContext context) => MaterialApp(
        title: '伝票デジタル化アプリ',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const _PlaceholderHomePage(
          key: ValueKey<String>('placeholder-home'),
        ),
      );
}

/// 実装が完了するまでの仮のホーム画面。
class _PlaceholderHomePage extends StatelessWidget {
  const _PlaceholderHomePage({super.key});

  @override
  Widget build(final BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('伝票デジタル化アプリ')),
        body: const Center(child: Text('実装予定（docs/design参照）')),
      );
}
