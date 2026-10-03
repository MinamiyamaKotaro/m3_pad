import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 伝票入力画面のグリッド内で、同額の列のグループ1つ分の個数セルを表す
/// ウィジェット。
///
/// 個数を中央に、左右に「-」「＋」の増減ボタン（スピンボタン）を表示する。
/// どの列の個数を増減するかは呼び出し元
/// （[VoucherSheetGrid](./voucher_sheet_grid.dart)）が決める。画面内で
/// のみ使用する。
class VoucherQuantityCell extends StatelessWidget {
  /// [VoucherQuantityCell] を生成する。
  const VoucherQuantityCell({
    required this.quantity,
    required this.onIncrement,
    super.key,
    this.onDecrement,
  });

  /// 表示する個数（グループ内の各列の個数の合計）。
  final int quantity;

  /// 「＋」押下時コールバック。
  final VoidCallback onIncrement;

  /// 「-」押下時コールバック。`null`の場合（個数が0）はボタンを無効化する。
  final VoidCallback? onDecrement;

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IntProperty('quantity', quantity))
      ..add(ObjectFlagProperty<VoidCallback>.has('onIncrement', onIncrement))
      ..add(ObjectFlagProperty<VoidCallback?>.has('onDecrement', onDecrement));
  }

  @override
  Widget build(final BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _stepperButton(context, icon: Icons.remove, onPressed: onDecrement),
          SizedBox(
            width: 18,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          _stepperButton(context, icon: Icons.add, onPressed: onIncrement),
        ],
      );

  /// 96px幅のセルに収まるよう、ボタンは[IconButton]（既定でも48px四方の
  /// タップ領域を確保しようとする）ではなく固定サイズの[InkWell]で実装
  /// する。
  Widget _stepperButton(
    final BuildContext context, {
    required final IconData icon,
    required final VoidCallback? onPressed,
  }) {
    final Color color = onPressed == null
        ? Theme.of(context).disabledColor
        : Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: 18,
      height: 18,
      child: InkWell(
        onTap: onPressed,
        child: Icon(icon, size: 12, color: color),
      ),
    );
  }
}
