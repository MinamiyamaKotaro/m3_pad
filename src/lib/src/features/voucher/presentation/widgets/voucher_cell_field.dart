import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/header.dart';
import '../../domain/entities/sheet_cell.dart';

/// 伝票入力画面のグリッド内で1セル分の入力を表すウィジェット。
///
/// 列（[Header]）の`isPriced=true`（MEMO以外）の場合は数量の増減ボタン
/// （スピンボタン）、`false`（MEMO列）の場合はタップして編集するテキスト
/// 入力を表示する。
class VoucherCellField extends StatelessWidget {
  /// [VoucherCellField] を生成する。
  const VoucherCellField({
    required this.header,
    required this.isEditing,
    required this.onTap,
    required this.onChanged,
    required this.onSubmitted,
    super.key,
    this.cell,
    this.editingText,
  });

  /// 列。`isPriced`で入力方式を切り替える。
  final Header header;

  /// セル。未入力の場合は`null`。
  final SheetCell? cell;

  /// 編集中フラグ。
  final bool isEditing;

  /// 編集中の入力テキスト。`isEditing=true`の場合のみ使用。
  final String? editingText;

  /// タップ時コールバック。
  final VoidCallback onTap;

  /// テキスト変更時コールバック。
  final ValueChanged<String> onChanged;

  /// 入力確定時コールバック。
  final VoidCallback onSubmitted;

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<Header>('header', header))
      ..add(DiagnosticsProperty<SheetCell?>('cell', cell))
      ..add(DiagnosticsProperty<bool>('isEditing', isEditing))
      ..add(StringProperty('editingText', editingText))
      ..add(ObjectFlagProperty<VoidCallback>.has('onTap', onTap))
      ..add(
        ObjectFlagProperty<ValueChanged<String>>.has('onChanged', onChanged),
      )
      ..add(ObjectFlagProperty<VoidCallback>.has('onSubmitted', onSubmitted));
  }

  @override
  Widget build(final BuildContext context) {
    if (header.isPriced) {
      return _buildStepper(context);
    }

    if (isEditing) {
      return TextFormField(
        autofocus: true,
        initialValue: editingText ?? '',
        onChanged: onChanged,
        onFieldSubmitted: (final String _) => onSubmitted(),
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
      );
    }

    final String displayValue = cell?.content ?? '';
    final TextStyle? baseStyle = Theme.of(context).textTheme.bodyMedium;
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          displayValue.isEmpty ? '–' : displayValue,
          style: displayValue.isEmpty
              ? baseStyle?.copyWith(color: Theme.of(context).disabledColor)
              : baseStyle,
        ),
      ),
    );
  }

  /// 数量の増減ボタン（スピンボタン）を表示する。`isPriced=true`の列
  /// （MEMO以外）でのみ使用する。96px幅のセルに収まるよう、ボタンは
  /// [IconButton]（既定でも48px四方のタップ領域を確保しようとする）では
  /// なく固定サイズの[InkWell]で実装する。
  Widget _buildStepper(final BuildContext context) {
    final int quantity = cell?.quantity ?? 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _stepperButton(
          context,
          icon: Icons.remove,
          onPressed: quantity > 0 ? () => _updateQuantity(quantity - 1) : null,
        ),
        SizedBox(
          width: 18,
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
        _stepperButton(
          context,
          icon: Icons.add,
          onPressed: () => _updateQuantity(quantity + 1),
        ),
      ],
    );
  }

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

  /// タップ→値変更→確定の順にコールバックを呼び出し、数量を[next]に
  /// 更新する。
  void _updateQuantity(final int next) {
    onTap();
    onChanged(next.toString());
    onSubmitted();
  }
}
