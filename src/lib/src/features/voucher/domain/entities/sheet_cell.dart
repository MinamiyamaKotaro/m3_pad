/// セルの値（ボディ）を表すドメインエンティティ。
///
/// DBの物理テーブル名は`t_cell`だが、Flutter標準の`Cell`系ウィジェット・
/// 概念との混同を避けるため、Dartクラス名は[SheetCell]とする。`Header`の
/// `isPriced`が`true`の列は[quantity]×[unitPriceApplied]方式
/// （[amount]はアプリ側で計算して保存）、`false`の列は[content]方式を
/// 使う。
class SheetCell {
  /// [SheetCell] を生成する。
  const SheetCell({
    required this.cellId,
    required this.rowId,
    required this.columnId,
    required this.createdAt,
    required this.updatedAt,
    this.content,
    this.quantity,
    this.unitPriceApplied,
    this.amount,
  });

  /// セルID。
  final String cellId;

  /// 行ID。`(rowId, columnId)`でユニーク。
  final String rowId;

  /// 列ID。`(rowId, columnId)`でユニーク。
  final String columnId;

  /// 内容。文字列・日付など数量概念のない列の値。`isPriced=false`の列で
  /// 使用。
  final String? content;

  /// 数量。`isPriced=true`の列でのみ使用。
  final int? quantity;

  /// 適用単価。入力時点で`HeaderPrice`から取得し保存した単価の
  /// スナップショット。後日の価格改定の影響を受けない。
  final int? unitPriceApplied;

  /// 金額。`quantity * unitPriceApplied`。アプリ側で計算して保存する。
  final int? amount;

  /// 作成日時。
  final DateTime createdAt;

  /// 更新日時。
  final DateTime updatedAt;
}
