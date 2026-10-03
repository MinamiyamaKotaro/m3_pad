import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/header.dart';
import '../../domain/entities/sheet_cell.dart';

/// 伝票入力画面のグリッド内で、MEMO列（`isPriced=false`の列）の1セル分の
/// 入力を表すウィジェット。
///
/// タップして編集するテキスト入力を表示する。価格対象の列の個数セルは、
/// 同額の列のグループ単位で[VoucherQuantityCell](./voucher_quantity_cell.dart)
/// が表示する。
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

  /// 列（MEMO列）。
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
}
