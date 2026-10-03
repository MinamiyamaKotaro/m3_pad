import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'csv_export_range_state.dart';
import 'voucher_providers.dart';

/// CSV出力画面（`MMM_005_VOUCHER`）の状態（[CsvExportRangeState]）を管理する
/// Riverpod Notifier。
///
/// 開始日・終了日の選択保持と、期間指定でのCSV出力（FR-3）を担う。共有
/// （Share）はOS機能の呼び出しのためpresentation層（Page）が行う。
class CsvExportRangeNotifier extends Notifier<CsvExportRangeState> {
  String? _sheetTemplateId;

  @override
  CsvExportRangeState build() => const CsvExportRangeState();

  /// 画面生成時に呼び出され、対象の伝票フォーマットIDを保持する。
  /// 「画面初期化」という操作の意味を明示するため、setterではなくメソッド
  /// とする。
  // ignore: use_setters_to_change_properties
  void init(final String sheetTemplateId) {
    _sheetTemplateId = sheetTemplateId;
  }

  /// 開始日の選択確定時に呼び出す。
  void setFrom(final DateTime from) {
    state = state.copyWith(from: from);
  }

  /// 終了日の選択確定時に呼び出す。
  void setTo(final DateTime to) {
    state = state.copyWith(to: to);
  }

  /// 選択中の期間でCSVを出力する。開始日・終了日が未選択の場合は失敗結果を
  /// 返す。
  Future<CsvExportResult> export() async {
    final DateTime? from = state.from;
    final DateTime? to = state.to;
    if (from == null || to == null) {
      return const CsvExportResult.failure('開始日と終了日を選択してください');
    }

    state = state.copyWith(isExporting: true);
    try {
      final String csvContent = await ref
          .read(exportSheetsToCsvByDateRangeUsecaseProvider)
          .call(sheetTemplateId: _requireTemplateId(), from: from, to: to);
      return CsvExportResult.success(csvContent);
    } on Exception catch (error) {
      return CsvExportResult.failure(error.toString());
    } finally {
      state = state.copyWith(isExporting: false);
    }
  }

  String _requireTemplateId() {
    final String? id = _sheetTemplateId;
    if (id == null) {
      throw StateError('sheetTemplateId is not initialized yet');
    }
    return id;
  }
}

/// [CsvExportRangeNotifier] を提供するプロバイダ。
final NotifierProvider<CsvExportRangeNotifier, CsvExportRangeState>
    csvExportRangeNotifierProvider =
    NotifierProvider<CsvExportRangeNotifier, CsvExportRangeState>(
  CsvExportRangeNotifier.new,
);
