/// 列（[Header](./header.dart)）ごとの単価改定履歴を表すドメインエンティティ。
///
/// 単価は期間（[effectiveFrom]〜[effectiveTo]）で管理し、価格改定時は既存
/// レコードの[effectiveTo]に改定日をセットして新しいレコードを追加する
/// （履歴は物理削除しない）。
class HeaderPrice {
  /// [HeaderPrice] を生成する。
  const HeaderPrice({
    required this.priceId,
    required this.columnId,
    required this.price,
    required this.effectiveFrom,
    required this.createdAt,
    required this.updatedAt,
    this.effectiveTo,
  });

  /// 価格ID。
  final String priceId;

  /// 対象の列。
  final String columnId;

  /// 単価（円）。
  final int price;

  /// 適用開始日（日付のみ）。
  final DateTime effectiveFrom;

  /// 適用終了日（日付のみ）。`null`なら現在も有効。
  final DateTime? effectiveTo;

  /// 作成日時。
  final DateTime createdAt;

  /// 更新日時。
  final DateTime updatedAt;
}
