import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/customer.dart';
import '../../domain/entities/enums/enums.dart';
import '../../domain/entities/header.dart';
import '../../domain/entities/sheet_cell.dart';
import '../../domain/entities/sheet_row.dart';
import '../../domain/entities/staff.dart';
import 'voucher_cell_field.dart';

/// 1組の来店・卓（[SheetRow]）を表す1行のウィジェット。
///
/// 「お名前」列・[VoucherCellField]を列数分・「合計金額」列（決済方法
/// トグル付き）・「担当」列（プルダウン）の順に横並びに配置する。
class VoucherDataRow extends StatelessWidget {
  /// [VoucherDataRow] を生成する。
  const VoucherDataRow({
    required this.row,
    required this.headers,
    required this.cellsByColumnId,
    required this.staffRoster,
    required this.customersById,
    required this.onCellTap,
    required this.onTextChanged,
    required this.onCommit,
    required this.onStaffChanged,
    required this.onPaymentMethodChanged,
    super.key,
    this.editingColumnId,
    this.editingText,
  });

  /// 行。
  final SheetRow row;

  /// 列一覧。`displayOrder`昇順。
  final List<Header> headers;

  /// 列ID別セルMap。該当なしの列は未入力として扱う。
  final Map<String, SheetCell> cellsByColumnId;

  /// スタッフ選択肢一覧。「担当」列プルダウンの選択肢。
  final List<Staff> staffRoster;

  /// 顧客ID別顧客Map。「お名前」列の氏名表示用。
  final Map<String, Customer> customersById;

  /// この行が編集中の場合のみ非`null`。「お名前」列編集中の場合は特別な
  /// 値`'customerName'`。
  final String? editingColumnId;

  /// 編集中の入力テキスト。
  final String? editingText;

  /// セルタップ時コールバック。
  final void Function(String columnId, String initialText) onCellTap;

  /// テキスト変更時コールバック。
  final ValueChanged<String> onTextChanged;

  /// 入力確定時コールバック。
  final VoidCallback onCommit;

  /// 担当変更時コールバック。
  final ValueChanged<String?> onStaffChanged;

  /// 決済方法変更時コールバック。
  final ValueChanged<PaymentMethod?> onPaymentMethodChanged;

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<SheetRow>('row', row))
      ..add(IterableProperty<Header>('headers', headers))
      ..add(
        DiagnosticsProperty<Map<String, SheetCell>>(
          'cellsByColumnId',
          cellsByColumnId,
        ),
      )
      ..add(IterableProperty<Staff>('staffRoster', staffRoster))
      ..add(
        DiagnosticsProperty<Map<String, Customer>>(
          'customersById',
          customersById,
        ),
      )
      ..add(StringProperty('editingColumnId', editingColumnId))
      ..add(StringProperty('editingText', editingText))
      ..add(
        ObjectFlagProperty<void Function(String, String)>.has(
          'onCellTap',
          onCellTap,
        ),
      )
      ..add(
        ObjectFlagProperty<ValueChanged<String>>.has(
          'onTextChanged',
          onTextChanged,
        ),
      )
      ..add(ObjectFlagProperty<VoidCallback>.has('onCommit', onCommit))
      ..add(
        ObjectFlagProperty<ValueChanged<String?>>.has(
          'onStaffChanged',
          onStaffChanged,
        ),
      )
      ..add(
        ObjectFlagProperty<ValueChanged<PaymentMethod?>>.has(
          'onPaymentMethodChanged',
          onPaymentMethodChanged,
        ),
      );
  }

  @override
  Widget build(final BuildContext context) => Row(
        children: <Widget>[
          SizedBox(width: 96, child: _buildNameCell(context)),
          ...headers.map(
            (final Header header) => SizedBox(
              width: 96,
              child: VoucherCellField(
                header: header,
                cell: cellsByColumnId[header.columnId],
                isEditing: editingColumnId == header.columnId,
                editingText:
                    editingColumnId == header.columnId ? editingText : null,
                onTap: () => onCellTap(
                  header.columnId,
                  header.isPriced
                      ? (cellsByColumnId[header.columnId]
                              ?.quantity
                              ?.toString() ??
                          '')
                      : (cellsByColumnId[header.columnId]?.content ?? ''),
                ),
                onChanged: onTextChanged,
                onSubmitted: onCommit,
              ),
            ),
          ),
          SizedBox(width: 96, child: _buildTotalCell(context)),
          SizedBox(width: 96, child: _buildStaffCell(context)),
        ],
      );

  Widget _buildNameCell(final BuildContext context) {
    if (editingColumnId == 'customerName') {
      return TextField(
        autofocus: true,
        controller: TextEditingController(text: editingText ?? ''),
        onChanged: onTextChanged,
        onSubmitted: (final String _) => onCommit(),
      );
    }
    final Customer? customer =
        row.customerId == null ? null : customersById[row.customerId];
    return InkWell(
      onTap: () => onCellTap('customerName', customer?.name ?? ''),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(customer?.name ?? '-様')),
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
    );
  }

  Widget _buildTotalCell(final BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text('¥${row.totalAmount}'),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _paymentChip(context, 'P', PaymentMethod.paypay),
              const SizedBox(width: 4),
              _paymentChip(context, 'カ', PaymentMethod.card),
            ],
          ),
        ],
      );

  Widget _paymentChip(
    final BuildContext context,
    final String label,
    final PaymentMethod method,
  ) {
    final bool active = row.paymentMethod == method;
    return InkWell(
      onTap: () => onPaymentMethodChanged(active ? null : method),
      child: Container(
        width: 20,
        height: 18,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: active
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildStaffCell(final BuildContext context) =>
      DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: row.staffId,
          isDense: true,
          hint: const Text('未定'),
          items: <DropdownMenuItem<String?>>[
            const DropdownMenuItem<String?>(child: Text('未定')),
            ...staffRoster.map(
              (final Staff staff) => DropdownMenuItem<String?>(
                value: staff.staffId,
                child: Text(staff.name),
              ),
            ),
          ],
          onChanged: onStaffChanged,
        ),
      );
}
