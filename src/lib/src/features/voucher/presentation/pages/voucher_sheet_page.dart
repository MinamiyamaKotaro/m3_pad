import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/notice_banner.dart';
import '../../domain/entities/sheet_detail.dart';
import '../controllers/voucher_sheet_effect.dart';
import '../controllers/voucher_sheet_effect_provider.dart';
import '../controllers/voucher_sheet_notifier.dart';
import '../controllers/voucher_sheet_state.dart';
import '../widgets/voucher_sheet_grid.dart';
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
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.onPrimary,
            foregroundColor: Theme.of(context).colorScheme.primary,
            child: const Text('寿'),
          ),
        ),
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('伝票入力'),
            Text('MMM_001_VOUCHER', style: TextStyle(fontSize: 11)),
          ],
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Text(
                '${widget.businessDate.month}月${widget.businessDate.day}日',
              ),
            ),
          ),
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
              child: VoucherSheetGrid(
                headers: detail.headers,
                unitPricesByColumnId: detail.unitPricesByColumnId,
                rows: detail.rows,
                cellsByRowIdAndColumnId: detail.cellsByRowIdAndColumnId,
                staffRoster: detail.staffRoster,
                customersById: detail.customersById,
                dailySummary: detail.dailySummary,
                editingRowId: state.editingRowId,
                editingColumnId: state.editingColumnId,
                editingText: state.editingText,
                onCellTap: notifier.startEditingCell,
                onTextChanged: notifier.updateEditingText,
                onCommit: notifier.commitCell,
                onStaffChanged: notifier.setRowStaff,
                onPaymentMethodChanged: notifier.setRowPaymentMethod,
                onAddRow: notifier.addRow,
              ),
            ),
          ],
        );
    }
  }
}
