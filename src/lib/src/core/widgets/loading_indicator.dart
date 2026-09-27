import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 読込中（Loading）状態を示す共通UIコンポーネント。
///
/// 画面中央に円形のプログレスインジケータを表示する。特定機能に依存しない
/// ため`core/widgets/`に配置し、Loading状態を持つ全ページから利用される。
class LoadingIndicator extends StatelessWidget {
  /// [LoadingIndicator] を生成する。
  const LoadingIndicator({super.key, this.message});

  /// インジケータ下に表示する補足文言。未指定時は非表示。
  final String? message;

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('message', message));
  }

  @override
  Widget build(final BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const CircularProgressIndicator(),
            if (message != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(message!),
            ],
          ],
        ),
      );
}
