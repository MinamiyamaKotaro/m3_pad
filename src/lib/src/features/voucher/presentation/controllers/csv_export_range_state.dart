/// CSV出力（`MMM_005_VOUCHER`）の期間出力（CsvExportRangeNotifier.export）
/// の実行結果。
///
/// 成功時は[csvContent]、失敗時は[errorMessage]のいずれか一方のみが非
/// `null`となる。
class CsvExportResult {
  /// 成功結果を生成する。
  const CsvExportResult.success(this.csvContent) : errorMessage = null;

  /// 失敗結果を生成する。
  const CsvExportResult.failure(this.errorMessage) : csvContent = null;

  /// 出力されたCSV文字列。成功時のみ非`null`。
  final String? csvContent;

  /// エラーメッセージ。失敗時のみ非`null`。
  final String? errorMessage;
}

/// CSV出力画面（`MMM_005_VOUCHER`）のUI状態（UiState）を表すクラス。
///
/// CsvExportRangeNotifierが保持・更新し、CsvExportRangePageが監視する。
class CsvExportRangeState {
  /// [CsvExportRangeState] を生成する。
  const CsvExportRangeState({this.from, this.to, this.isExporting = false});

  /// 開始日。未選択の場合は`null`。
  final DateTime? from;

  /// 終了日。未選択の場合は`null`。
  final DateTime? to;

  /// CSV出力中フラグ。
  final bool isExporting;

  /// 一部のプロパティのみを変更した新しい [CsvExportRangeState] を生成する。
  CsvExportRangeState copyWith({
    final DateTime? from,
    final DateTime? to,
    final bool? isExporting,
  }) =>
      CsvExportRangeState(
        from: from ?? this.from,
        to: to ?? this.to,
        isExporting: isExporting ?? this.isExporting,
      );
}
