import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/customer.dart';
import '../../domain/entities/daily_payment_summary.dart';
import '../../domain/entities/enums/enums.dart';
import '../../domain/entities/header.dart';
import '../../domain/entities/sheet_cell.dart';
import '../../domain/entities/sheet_row.dart';
import '../../domain/entities/staff.dart';
import 'voucher_add_row_button.dart';
import 'voucher_cell_field.dart';
import 'voucher_daily_summary_row.dart';
import 'voucher_header_row.dart';
import 'voucher_name_cell.dart';
import 'voucher_staff_select_cell.dart';
import 'voucher_total_cell.dart';

/// 伝票入力画面の表本体（[VoucherHeaderRow]〜データ行〜
/// [VoucherDailySummaryRow]）を、縦・横スクロール可能なグリッドとして
/// 表示するウィジェット。
///
/// 紙伝票のヘッダー行固定表示（FR-1）を再現するため、「お名前」列を左端、
/// 「合計金額」列・「担当」列を右端に横スクロールしても常に視認できる
/// よう固定し、ヘッダー行を縦スクロールしても常に画面上部に、本日の合計行
/// （[VoucherDailySummaryRow]）を常に画面下部に固定表示する。「行を追加」
/// ボタン（[VoucherAddRowButton]）は縦方向には通常の行として流れる一方、
/// 横方向は「お名前」列と同じ固定領域に配置し、価格列が多くても見失わない
/// ようにする。
class VoucherSheetGrid extends StatefulWidget {
  /// [VoucherSheetGrid] を生成する。
  const VoucherSheetGrid({
    required this.headers,
    required this.unitPricesByColumnId,
    required this.rows,
    required this.cellsByRowIdAndColumnId,
    required this.staffRoster,
    required this.customersById,
    required this.dailySummary,
    required this.onCellTap,
    required this.onTextChanged,
    required this.onCommit,
    required this.onStaffChanged,
    required this.onPaymentMethodChanged,
    required this.onAddRow,
    super.key,
    this.editingRowId,
    this.editingColumnId,
    this.editingText,
  });

  /// 列一覧。`displayOrder`昇順。
  final List<Header> headers;

  /// 列ID別の現在の適用単価Map。
  final Map<String, int> unitPricesByColumnId;

  /// 行一覧。`rowOrder`昇順。
  final List<SheetRow> rows;

  /// 行ID・列ID別セルMap。
  final Map<String, Map<String, SheetCell>> cellsByRowIdAndColumnId;

  /// スタッフ選択肢一覧。「担当」列プルダウンの選択肢。
  final List<Staff> staffRoster;

  /// 顧客ID別顧客Map。「お名前」列の氏名表示用。
  final Map<String, Customer> customersById;

  /// 日次集計。
  final DailyPaymentSummary dailySummary;

  /// 編集中の行ID。
  final String? editingRowId;

  /// 編集中の列ID。「お名前」列編集中の場合は特別な値`'customerName'`。
  final String? editingColumnId;

  /// 編集中の入力テキスト。
  final String? editingText;

  /// セルタップ時コールバック。
  final void Function(String rowId, String columnId, String initialText)
      onCellTap;

  /// テキスト変更時コールバック。
  final ValueChanged<String> onTextChanged;

  /// 入力確定時コールバック。
  final VoidCallback onCommit;

  /// 担当変更時コールバック。
  final void Function(String rowId, String? staffId) onStaffChanged;

  /// 決済方法変更時コールバック。
  final void Function(String rowId, PaymentMethod? method)
      onPaymentMethodChanged;

  /// 「行を追加」ボタンタップ時コールバック。
  final VoidCallback onAddRow;

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IterableProperty<Header>('headers', headers))
      ..add(
        DiagnosticsProperty<Map<String, int>>(
          'unitPricesByColumnId',
          unitPricesByColumnId,
        ),
      )
      ..add(IterableProperty<SheetRow>('rows', rows))
      ..add(
        DiagnosticsProperty<Map<String, Map<String, SheetCell>>>(
          'cellsByRowIdAndColumnId',
          cellsByRowIdAndColumnId,
        ),
      )
      ..add(IterableProperty<Staff>('staffRoster', staffRoster))
      ..add(
        DiagnosticsProperty<Map<String, Customer>>(
          'customersById',
          customersById,
        ),
      )
      ..add(
        DiagnosticsProperty<DailyPaymentSummary>(
          'dailySummary',
          dailySummary,
        ),
      )
      ..add(StringProperty('editingRowId', editingRowId))
      ..add(StringProperty('editingColumnId', editingColumnId))
      ..add(StringProperty('editingText', editingText))
      ..add(
        ObjectFlagProperty<void Function(String, String, String)>.has(
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
        ObjectFlagProperty<void Function(String, String?)>.has(
          'onStaffChanged',
          onStaffChanged,
        ),
      )
      ..add(
        ObjectFlagProperty<void Function(String, PaymentMethod?)>.has(
          'onPaymentMethodChanged',
          onPaymentMethodChanged,
        ),
      )
      ..add(ObjectFlagProperty<VoidCallback>.has('onAddRow', onAddRow));
  }

  @override
  State<VoucherSheetGrid> createState() => _VoucherSheetGridState();
}

class _VoucherSheetGridState extends State<VoucherSheetGrid> {
  static const double _nameColWidth = 140;
  static const double _priceColWidth = 96;
  static const double _totalColWidth = 140;
  static const double _staffColWidth = 96;
  static const double _headerHeight = 72;
  static const double _rowHeight = 56;
  static const double _footerHeight = 92;

  /// MEMOセルのテキストの左右パディング合計（横方向の折り返し幅計算用）と
  /// 上下パディング合計（縦方向の必要高さ計算用）に共通して用いる値。
  static const double _cellTextPadding = 16;

  final _LinkedScrollControllers _vertical = _LinkedScrollControllers(3);
  final _LinkedScrollControllers _horizontal = _LinkedScrollControllers(3);

  @override
  void dispose() {
    _vertical.dispose();
    _horizontal.dispose();
    super.dispose();
  }

  /// 表示・描画順の列一覧を組み立てる。
  ///
  /// 1. `isVisible=true`の列のみを対象とする（非表示列は伝票グリッド上の
  ///    列としては描画しないが、既存セルの数量・単価・合計金額計算には
  ///    影響しない。[_computeRowHeights]・合計金額の算出は全列を対象とする
  ///    ロジック側で行うため）。
  /// 2. 価格対象の列（`isPriced=true`）を、現在の単価が同額のものが隣接
  ///    するよう並べ替える（[VoucherHeaderRow](./voucher_header_row.dart)
  ///    が隣接する同額列を1セルにまとめて改行表示するため）。並べ替えは
  ///    価格ごとの初出順を保つ安定グルーピングとし、単価未登録・非価格
  ///    対象の列は元の位置を保つ。
  /// 3. 非価格対象の列（MEMO）は、常に価格対象の列より後ろに描画する
  ///    （ヘッダー管理画面で列を追加すると`displayOrder`がMEMOより後ろに
  ///    なるため、描画順で補正する）。
  List<Header> get _visibleHeaders {
    final List<Header> visible = widget.headers
        .where((final Header header) => header.isVisible)
        .toList();
    final List<Header> priced = <Header>[];
    final List<Header> nonPriced = <Header>[];
    for (final Header header in visible) {
      if (header.isPriced) {
        priced.add(header);
      } else {
        nonPriced.add(header);
      }
    }
    return <Header>[..._groupByPrice(priced), ...nonPriced];
  }

  /// [headers] を、現在の単価（`widget.unitPricesByColumnId`）が同額のもの
  /// が隣接するよう並べ替える。価格ごとの初出順を保つ安定グルーピングと
  /// する。
  List<Header> _groupByPrice(final List<Header> headers) {
    final Map<int, List<Header>> headersByPrice = <int, List<Header>>{};
    final List<Object> firstSeenOrder = <Object>[];
    for (final Header header in headers) {
      final int? price = widget.unitPricesByColumnId[header.columnId];
      if (price == null) {
        firstSeenOrder.add(header);
        continue;
      }
      if (!headersByPrice.containsKey(price)) {
        headersByPrice[price] = <Header>[];
        firstSeenOrder.add(price);
      }
      headersByPrice[price]!.add(header);
    }
    return <Header>[
      for (final Object key in firstSeenOrder)
        if (key is Header) key else ...headersByPrice[key as int]!,
    ];
  }

  @override
  Widget build(final BuildContext context) {
    final List<Header> visibleHeaders = _visibleHeaders;
    final double middleWidth = _priceColWidth * visibleHeaders.length;
    final List<double> rowHeights = _computeRowHeights(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          width: _nameColWidth,
          child: _buildNameColumn(context, rowHeights),
        ),
        Expanded(
          child: _buildPriceColumns(
            context,
            visibleHeaders,
            middleWidth,
            rowHeights,
          ),
        ),
        SizedBox(
          width: _totalColWidth + _staffColWidth,
          child: _buildTrailingColumns(context, rowHeights),
        ),
      ],
    );
  }

  /// 行ごとの高さ一覧を算出する。ミニマムは「合計金額」列の高さ
  /// （[_rowHeight]）とし、MEMO列（`isPriced=false`の列）の入力量に応じて
  /// 折り返し行数が増える場合は、その分だけ高さを広げる。
  List<double> _computeRowHeights(final BuildContext context) {
    final TextStyle style =
        Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
    return widget.rows.map((final SheetRow row) {
      final Map<String, SheetCell> cells =
          widget.cellsByRowIdAndColumnId[row.rowId] ??
              const <String, SheetCell>{};
      double height = _rowHeight;
      for (final Header header in widget.headers) {
        if (header.isPriced) {
          continue;
        }
        final String content = cells[header.columnId]?.content ?? '';
        if (content.isEmpty) {
          continue;
        }
        final TextPainter painter = TextPainter(
          text: TextSpan(text: content, style: style),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: _priceColWidth - _cellTextPadding);
        final double needed = painter.height + _cellTextPadding;
        if (needed > height) {
          height = needed;
        }
      }
      return height;
    }).toList();
  }

  Widget _buildNameColumn(
    final BuildContext context,
    final List<double> rowHeights,
  ) =>
      Column(
        children: <Widget>[
          _fixedCell(
            context,
            height: _headerHeight,
            border: _cellBorder(context),
            child: Text(
              'お名前',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _vertical.controllers[0],
              child: Column(
                children: <Widget>[
                  for (int i = 0; i < widget.rows.length; i++)
                    Container(
                      height: rowHeights[i],
                      decoration: BoxDecoration(border: _cellBorder(context)),
                      child: _nameCellFor(widget.rows[i]),
                    ),
                  Container(
                    height: _rowHeight,
                    decoration: BoxDecoration(
                      border: _cellBorder(context, right: false),
                    ),
                    child: VoucherAddRowButton(onTap: widget.onAddRow),
                  ),
                ],
              ),
            ),
          ),
          _fixedCell(
            context,
            height: _footerHeight,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            border: _cellBorder(context, top: true, bottom: false),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '本日の合計',
                textAlign: TextAlign.right,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      );

  Widget _buildPriceColumns(
    final BuildContext context,
    final List<Header> visibleHeaders,
    final double middleWidth,
    final List<double> rowHeights,
  ) =>
      Column(
        children: <Widget>[
          SizedBox(
            height: _headerHeight,
            child: SingleChildScrollView(
              controller: _horizontal.controllers[0],
              scrollDirection: Axis.horizontal,
              child: VoucherHeaderRow(
                headers: visibleHeaders,
                unitPricesByColumnId: widget.unitPricesByColumnId,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _vertical.controllers[1],
              child: SingleChildScrollView(
                controller: _horizontal.controllers[1],
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: <Widget>[
                    for (int i = 0; i < widget.rows.length; i++)
                      SizedBox(
                        height: rowHeights[i],
                        width: middleWidth,
                        child: Row(
                          children: _priceCellsFor(
                            visibleHeaders,
                            widget.rows[i],
                            rowHeights[i],
                          ),
                        ),
                      ),
                    Container(
                      height: _rowHeight,
                      width: middleWidth,
                      decoration: BoxDecoration(
                        border: _cellBorder(context, right: false),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: _footerHeight,
            child: SingleChildScrollView(
              controller: _horizontal.controllers[2],
              scrollDirection: Axis.horizontal,
              child: Container(
                width: middleWidth,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: _cellBorder(context, top: true, bottom: false),
                ),
              ),
            ),
          ),
        ],
      );

  Widget _buildTrailingColumns(
    final BuildContext context,
    final List<double> rowHeights,
  ) =>
      Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              _fixedCell(
                context,
                height: _headerHeight,
                width: _totalColWidth,
                border: _cellBorder(context),
                child: Text(
                  '合計金額',
                  style: Theme.of(
                    context,
                  )
                      .textTheme
                      .labelMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              _fixedCell(
                context,
                height: _headerHeight,
                width: _staffColWidth,
                border: _cellBorder(context),
                child: Text(
                  '担当',
                  style: Theme.of(
                    context,
                  )
                      .textTheme
                      .labelMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _vertical.controllers[2],
              child: Column(
                children: <Widget>[
                  for (int i = 0; i < widget.rows.length; i++)
                    SizedBox(
                      height: rowHeights[i],
                      child: _trailingCellsFor(
                        context,
                        widget.rows[i],
                        rowHeights[i],
                      ),
                    ),
                  Container(
                    height: _rowHeight,
                    decoration: BoxDecoration(border: _cellBorder(context)),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: _footerHeight,
            child: Row(
              children: <Widget>[
                Container(
                  width: _totalColWidth,
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    border: _cellBorder(
                      context,
                      top: true,
                      right: false,
                      bottom: false,
                    ),
                  ),
                  child: VoucherDailySummaryRow(summary: widget.dailySummary),
                ),
                Container(
                  width: _staffColWidth,
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    border: _cellBorder(
                      context,
                      top: true,
                      right: false,
                      bottom: false,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _fixedCell(
    final BuildContext context, {
    required final double height,
    required final Widget child,
    final double? width,
    final Color? color,
    final Border? border,
  }) =>
      Container(
        height: height,
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: color ?? Theme.of(context).colorScheme.surface,
          border: border,
        ),
        child: child,
      );

  /// セル1つ分の罫線（外枠）を生成する。既定では右・下罫線のみを引く
  /// （紙伝票の表組みの見た目に合わせる）。`top=true`の場合は本日の合計行
  /// （表末尾）用に上罫線に差し替える。
  Border _cellBorder(
    final BuildContext context, {
    final bool top = false,
    final bool right = true,
    final bool bottom = true,
  }) {
    final BorderSide side = BorderSide(
      color: Theme.of(context).colorScheme.outline,
    );
    return Border(
      top: top ? side : BorderSide.none,
      right: right ? side : BorderSide.none,
      bottom: bottom ? side : BorderSide.none,
    );
  }

  /// [child] を、幅は親いっぱいに保ったまま（横方向は`Column`の
  /// `crossAxisAlignment.stretch`により子ウィジェット自身の配置ロジックに
  /// 委ねる）、縦方向のみ中央揃えするラッパー。MEMOの折り返しなどで行の
  /// 高さが本来の必要高さより大きくなった場合に、スピンボタン・「担当」
  /// プルダウン・「合計金額」の内容が行の高さに追従して中央に表示される
  /// ようにするために使用する。
  Widget _verticalCenter(final Widget child) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[child],
      );

  Widget _nameCellFor(final SheetRow row) {
    final bool isEditingName = widget.editingRowId == row.rowId &&
        widget.editingColumnId == 'customerName';
    final Customer? customer =
        row.customerId == null ? null : widget.customersById[row.customerId];
    return VoucherNameCell(
      customer: customer,
      isEditing: isEditingName,
      editingText: isEditingName ? widget.editingText : null,
      onTap: () =>
          widget.onCellTap(row.rowId, 'customerName', customer?.name ?? ''),
      onChanged: widget.onTextChanged,
      onSubmitted: widget.onCommit,
    );
  }

  List<Widget> _priceCellsFor(
    final List<Header> visibleHeaders,
    final SheetRow row,
    final double rowHeight,
  ) {
    final Map<String, SheetCell> cells =
        widget.cellsByRowIdAndColumnId[row.rowId] ??
            const <String, SheetCell>{};
    final bool isEditingRow = widget.editingRowId == row.rowId;
    return visibleHeaders.map((final Header header) {
      final SheetCell? cell = cells[header.columnId];
      final bool isEditingCell =
          isEditingRow && widget.editingColumnId == header.columnId;
      return Container(
        width: _priceColWidth,
        height: rowHeight,
        decoration: BoxDecoration(border: _cellBorder(context)),
        child: _verticalCenter(
          VoucherCellField(
            header: header,
            cell: cell,
            isEditing: isEditingCell,
            editingText: isEditingCell ? widget.editingText : null,
            onTap: () => widget.onCellTap(
              row.rowId,
              header.columnId,
              header.isPriced
                  ? (cell?.quantity?.toString() ?? '')
                  : (cell?.content ?? ''),
            ),
            onChanged: widget.onTextChanged,
            onSubmitted: widget.onCommit,
          ),
        ),
      );
    }).toList();
  }

  Widget _trailingCellsFor(
    final BuildContext context,
    final SheetRow row,
    final double rowHeight,
  ) =>
      Row(
        children: <Widget>[
          Container(
            width: _totalColWidth,
            height: rowHeight,
            decoration: BoxDecoration(border: _cellBorder(context)),
            child: _verticalCenter(
              VoucherTotalCell(
                amount: row.totalAmount,
                paymentMethod: row.paymentMethod,
                onPaymentMethodChanged: (final PaymentMethod? method) =>
                    widget.onPaymentMethodChanged(row.rowId, method),
              ),
            ),
          ),
          Container(
            width: _staffColWidth,
            height: rowHeight,
            decoration: BoxDecoration(border: _cellBorder(context)),
            child: _verticalCenter(
              VoucherStaffSelectCell(
                staffId: row.staffId,
                staffRoster: widget.staffRoster,
                onChanged: (final String? staffId) =>
                    widget.onStaffChanged(row.rowId, staffId),
              ),
            ),
          ),
        ],
      );
}

/// 複数の[ScrollController]の表示位置を相互に同期させるヘルパー。
///
/// お名前列・価格列・合計金額/担当列の3領域を縦スクロールで、
/// ヘッダー行・データ行・本日の合計行の3領域を横スクロールでそれぞれ
/// 連動させるために使用する（画面内でのみ使用する）。
class _LinkedScrollControllers {
  _LinkedScrollControllers(final int count)
      : controllers = List<ScrollController>.generate(
          count,
          (final int index) => ScrollController(),
        ) {
    for (final ScrollController controller in controllers) {
      controller.addListener(() => _onScroll(controller));
    }
  }

  /// 相互に同期する[ScrollController]一覧。
  final List<ScrollController> controllers;

  bool _isSyncing = false;

  void _onScroll(final ScrollController source) {
    if (_isSyncing || !source.hasClients) {
      return;
    }
    _isSyncing = true;
    for (final ScrollController controller in controllers) {
      if (controller == source || !controller.hasClients) {
        continue;
      }
      final double target = source.offset.clamp(
        controller.position.minScrollExtent,
        controller.position.maxScrollExtent,
      );
      controller.jumpTo(target);
    }
    _isSyncing = false;
  }

  /// 保持する全[ScrollController]を破棄する。
  void dispose() {
    for (final ScrollController controller in controllers) {
      controller.dispose();
    }
  }
}
