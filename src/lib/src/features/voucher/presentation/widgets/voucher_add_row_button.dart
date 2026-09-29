import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 「行を追加」ボタンを表すウィジェット。
///
/// データ行一覧の最後、本日の合計行の直前の行として、「お名前」列と
/// 同じ横スクロールしない領域に配置する。タップで行を追加する（FR-1）。
class VoucherAddRowButton extends StatelessWidget {
  /// [VoucherAddRowButton] を生成する。
  const VoucherAddRowButton({required this.onTap, super.key});

  /// タップ時コールバック。
  final VoidCallback onTap;

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<VoidCallback>.has('onTap', onTap));
  }

  @override
  Widget build(final BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Center(
          child: OutlinedButton.icon(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              visualDensity: VisualDensity.compact,
              minimumSize: Size.zero,
            ),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('行を追加', style: TextStyle(fontSize: 12)),
          ),
        ),
      );
}
