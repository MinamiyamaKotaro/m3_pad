import 'enums/enums.dart';

/// 伝票の列定義（ヘッダー）を表すドメインエンティティ。
///
/// [name]・[displayOrder]・入力型（[typeId]）・価格対象かどうか
/// （[isPriced]）を持つ。単価そのものは保持せず、価格改定履歴である
/// `HeaderPrice`から取得する。
class Header {
  /// [Header] を生成する。
  const Header({
    required this.columnId,
    required this.sheetTemplateId,
    required this.typeId,
    required this.name,
    required this.displayOrder,
    required this.isPriced,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 列ID。
  final String columnId;

  /// どのフォーマットの列か。
  final String sheetTemplateId;

  /// 入力値の型。
  final int typeId;

  /// 列名（例:「チャージ」「お茶ハイ」）。
  final String name;

  /// 表示順。昇順で表示する。
  final int displayOrder;

  /// 価格対象フラグ。`true`の場合、数量×単価方式のセルとなる。
  final bool isPriced;

  /// 論理削除状態。
  final RecordStatus status;

  /// 作成日時。
  final DateTime createdAt;

  /// 更新日時。
  final DateTime updatedAt;
}
