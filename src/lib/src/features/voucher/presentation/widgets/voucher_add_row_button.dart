import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 「行を追加」ボタンを表す行ウィジェット。
///
/// データ行一覧の最後、本日の合計行の直前の行として表に組み込む。
/// タップで行を追加する（FR-1）。
class VoucherAddRowButton extends StatelessWidget {
  /// [VoucherAddRowButton] を生成する。
  const VoucherAddRowButton({
    required this.columnCount,
    required this.onTap,
    super.key,
  });

  /// セルを列全体にまたがって描画するための合計列数。
  final int columnCount;

  /// タップ時コールバック。
  final VoidCallback onTap;

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IntProperty('columnCount', columnCount))
      ..add(ObjectFlagProperty<VoidCallback>.has('onTap', onTap));
  }

  @override
  Widget build(final BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: OutlinedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.add),
            label: const Text('行を追加'),
          ),
        ),
      );
}
