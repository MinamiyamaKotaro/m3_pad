/// 伝票入力画面（`MMM_001_VOUCHER`）における副作用（Side Effect）の種別。
enum VoucherSheetEffectKind {
  /// セル・行の付帯情報の入力・更新が失敗した。
  cellInputFailed,

  /// CSV出力が成功した。
  exportSucceeded,

  /// CSV出力が失敗した。
  exportFailed,
}

/// 伝票入力画面（`MMM_001_VOUCHER`）における副作用（Side Effect）を表す型。
///
/// 状態（VoucherSheetState）としては保持せず、VoucherSheetNotifierから
/// VoucherSheetPageへ1回限り通知される。
class VoucherSheetEffect {
  /// [VoucherSheetEffect] を生成する。
  const VoucherSheetEffect({
    required this.kind,
    required this.message,
    this.csvContent,
  });

  /// 種別。
  final VoucherSheetEffectKind kind;

  /// 画面上部のお知らせ表示に使う文言。
  final String message;

  /// 共有シート（Share）に渡すCSV内容。`kind`が`exportSucceeded`の場合
  /// 必須。
  final String? csvContent;
}
