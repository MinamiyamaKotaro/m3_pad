import 'enums/enums.dart';

/// 1組の来店・卓（データ行）を表すドメインエンティティ。
///
/// DBの物理テーブル名は`t_row`だが、Flutter標準の`Row`ウィジェットとの
/// 名称衝突を避けるため、Dartクラス名は[SheetRow]とする。配下の
/// `SheetCell`の`amount`合計は[totalAmount]にキャッシュされ、DBトリガー
/// により自動更新される。
class SheetRow {
  /// [SheetRow] を生成する。
  const SheetRow({
    required this.rowId,
    required this.sheetInstanceId,
    required this.rowOrder,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.customerId,
    this.staffId,
    this.paymentMethod,
  });

  /// 行ID。
  final String rowId;

  /// どの日の伝票の行か。
  final String sheetInstanceId;

  /// 紐付く顧客。未登録（新規客）の来店は`null`。画面上は「お名前」列に
  /// 「-様」＋「NEW」マークを表示する。
  final String? customerId;

  /// 担当スタッフ（会計を行った人）。行右端の「担当」列で選択する。
  final String? staffId;

  /// 表示順。
  final int rowOrder;

  /// 合計金額。`SheetCell`の`amount`合計のキャッシュ。DBトリガーにより
  /// 自動更新されるため、アプリ側から直接書き込まない。
  final int totalAmount;

  /// 決済方法。「合計金額」列に隣接する「P」「カ」の丸印に対応。`null`は
  /// 現金決済（どちらにも丸をつけない）。
  final PaymentMethod? paymentMethod;

  /// 論理削除状態。
  final RecordStatus status;

  /// 作成日時。
  final DateTime createdAt;

  /// 更新日時。
  final DateTime updatedAt;
}
