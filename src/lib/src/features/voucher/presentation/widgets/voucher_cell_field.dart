import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/header.dart';
import '../../domain/entities/sheet_cell.dart';

/// VoucherDataRow内の1セル分の入力ウィジェット。
///
/// 列（[Header]）の`isPriced`に応じて、数量入力（数値キーボード）または
/// テキスト入力を切り替える。非編集時は保存済みの[SheetCell]の表示値
/// （`isPriced=true`の場合は`quantity`、`false`の場合は`content`）を表示
/// する。
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
    if (isEditing) {
      return TextField(
        autofocus: true,
        controller: TextEditingController(text: editingText ?? '')
          ..selection = TextSelection.collapsed(
            offset: (editingText ?? '').length,
          ),
        keyboardType:
            header.isPriced ? TextInputType.number : TextInputType.text,
        textAlign: header.isPriced ? TextAlign.right : TextAlign.left,
        onChanged: onChanged,
        onSubmitted: (final String _) => onSubmitted(),
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
      );
    }

    final String displayValue = header.isPriced
        ? (cell?.quantity?.toString() ?? '')
        : (cell?.content ?? '');

    return InkWell(
      onTap: onTap,
      child: Container(
        alignment:
            header.isPriced ? Alignment.centerRight : Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          displayValue.isEmpty ? '–' : displayValue,
          style: displayValue.isEmpty
              ? TextStyle(color: Theme.of(context).disabledColor)
              : null,
        ),
      ),
    );
  }
}
