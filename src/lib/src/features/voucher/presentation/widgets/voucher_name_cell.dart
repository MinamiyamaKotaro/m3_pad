import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/customer.dart';

/// 伝票入力画面のグリッド内で1行分の「お名前」列セルを表すウィジェット。
///
/// 顧客が紐付いている場合は氏名＋「様」、未登録（新規客）の場合は「-様」＋
/// 「NEW」マークを表示する。タップでインライン編集に切り替わる。
class VoucherNameCell extends StatelessWidget {
  /// [VoucherNameCell] を生成する。
  const VoucherNameCell({
    required this.customer,
    required this.isEditing,
    required this.onTap,
    required this.onChanged,
    required this.onSubmitted,
    super.key,
    this.editingText,
  });

  /// 紐付く顧客。未登録（新規客）の場合は`null`。
  final Customer? customer;

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
      ..add(DiagnosticsProperty<Customer?>('customer', customer))
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
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: TextFormField(
          autofocus: true,
          initialValue: editingText ?? '',
          onChanged: onChanged,
          onFieldSubmitted: (final String _) => onSubmitted(),
        ),
      );
    }
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                customer == null ? '-様' : '${customer!.name} 様',
              ),
            ),
            if (customer == null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'NEW',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 9,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
