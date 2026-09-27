import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/notice_banner.dart';
import '../../domain/entities/enums/enums.dart';
import '../../domain/entities/sheet_cell.dart';
import '../../domain/entities/sheet_detail.dart';
import '../../domain/entities/sheet_row.dart';
import '../controllers/voucher_sheet_effect.dart';
import '../controllers/voucher_sheet_effect_provider.dart';
import '../controllers/voucher_sheet_notifier.dart';
import '../controllers/voucher_sheet_state.dart';
import '../widgets/voucher_add_row_button.dart';
import '../widgets/voucher_daily_summary_row.dart';
import '../widgets/voucher_data_row.dart';
import '../widgets/voucher_header_row.dart';
import '../widgets/voucher_staff_bar.dart';

/// 伝票入力画面（画面ID: `MMM_001_VOUCHER`）。
///
/// 紙伝票「寿」フォーマットと同じ列構成・ヘッダー固定表示を再現し、
/// 来店・卓ごとの行入力、金額の自動計算表示、スタッフ欄・日次集計の表示、
/// CSV出力を行う（FR-1〜FR-3）。
class VoucherSheetPage extends ConsumerStatefulWidget {
  /// [VoucherSheetPage] を生成する。
  const VoucherSheetPage({
    required this.sheetTemplateId,
    required this.businessDate,
    super.key,
  });

  /// 表示対象の伝票フォーマットID。
  final String sheetTemplateId;

  /// 表示対象の営業日。
  final DateTime businessDate;

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('sheetTemplateId', sheetTemplateId))
      ..add(DiagnosticsProperty<DateTime>('businessDate', businessDate));
  }

  @override
  ConsumerState<VoucherSheetPage> createState() => _VoucherSheetPageState();
}

class _VoucherSheetPageState extends ConsumerState<VoucherSheetPage> {
  @override
  void initState() {
    super.initState();
    unawaited(
      Future<void>.microtask(
        () => ref.read(voucherSheetNotifierProvider.notifier).load(
              sheetTemplateId: widget.sheetTemplateId,
              businessDate: widget.businessDate,
            ),
      ),
    );
  }

  @override
  Widget build(final BuildContext context) {
    ref.listen<VoucherSheetEffect?>(voucherSheetEffectProvider, (
      final VoucherSheetEffect? previous,
      final VoucherSheetEffect? next,
    ) {
      if (next == null || identical(previous, next)) {
        return;
      }
      if (next.kind == VoucherSheetEffectKind.exportSucceeded &&
          next.csvContent != null) {
        unawaited(SharePlus.instance.share(ShareParams(text: next.csvContent)));
      }
      ScaffoldMessenger.of(context).showMaterialBanner(
        MaterialBanner(
          content: NoticeBanner(
            message: next.message,
            tone: next.kind == VoucherSheetEffectKind.exportSucceeded
                ? NoticeTone.success
                : NoticeTone.error,
            onDismiss: () =>
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
          ),
          actions: const <Widget>[SizedBox.shrink()],
        ),
      );
    });

    final VoucherSheetState state = ref.watch(voucherSheetNotifierProvider);
    final VoucherSheetNotifier notifier = ref.read(
      voucherSheetNotifierProvider.notifier,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('伝票入力'),
        actions: <Widget>[
          IconButton(
            icon: state.isExporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.ios_share),
            onPressed: state.status == VoucherSheetStatus.success
                ? notifier.exportCsv
                : null,
          ),
        ],
      ),
      body: _buildBody(context, state, notifier),
    );
  }

  Widget _buildBody(
    final BuildContext context,
    final VoucherSheetState state,
    final VoucherSheetNotifier notifier,
  ) {
    switch (state.status) {
      case VoucherSheetStatus.initial:
      case VoucherSheetStatus.loading:
        return const LoadingIndicator();
      case VoucherSheetStatus.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(state.errorMessage ?? ''),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => notifier.retry(
                  sheetTemplateId: widget.sheetTemplateId,
                  businessDate: widget.businessDate,
                ),
                child: const Text('再試行'),
              ),
            ],
          ),
        );
      case VoucherSheetStatus.empty:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('まだ行がありません'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: notifier.addRow,
                child: const Text('行を追加'),
              ),
            ],
          ),
        );
      case VoucherSheetStatus.success:
        final SheetDetail detail = state.sheetDetail!;
        return Column(
          children: <Widget>[
            VoucherStaffBar(
              shifts: detail.staffShifts,
              staffRoster: detail.staffRoster,
              editingStaffShiftId: state.editingStaffShiftId,
              editingStaffShiftField: state.editingStaffShiftField,
              onNameChanged: notifier.setStaffShiftName,
              onTimeTap: notifier.startEditingStaffShiftTime,
              onTimeCommit: notifier.commitStaffShiftTime,
              onDrinkBackCommit: notifier.setStaffShiftDrinkBack,
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      VoucherHeaderRow(
                        headers: detail.headers,
                        unitPricesByColumnId: detail.unitPricesByColumnId,
                      ),
                      ...detail.rows.map(
                        (final SheetRow row) => VoucherDataRow(
                          row: row,
                          headers: detail.headers,
                          cellsByColumnId:
                              detail.cellsByRowIdAndColumnId[row.rowId] ??
                                  const <String, SheetCell>{},
                          staffRoster: detail.staffRoster,
                          customersById: detail.customersById,
                          editingColumnId: state.editingRowId == row.rowId
                              ? state.editingColumnId
                              : null,
                          editingText: state.editingRowId == row.rowId
                              ? state.editingText
                              : null,
                          onCellTap:
                              (final String columnId, final String text) =>
                                  notifier.startEditingCell(
                            row.rowId,
                            columnId,
                            text,
                          ),
                          onTextChanged: notifier.updateEditingText,
                          onCommit: notifier.commitCell,
                          onStaffChanged: (final String? staffId) =>
                              notifier.setRowStaff(row.rowId, staffId),
                          onPaymentMethodChanged:
                              (final PaymentMethod? method) => notifier
                                  .setRowPaymentMethod(row.rowId, method),
                        ),
                      ),
                      VoucherAddRowButton(
                        columnCount: detail.headers.length + 3,
                        onTap: notifier.addRow,
                      ),
                      VoucherDailySummaryRow(
                        summary: detail.dailySummary,
                        headers: detail.headers,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
    }
  }
}
