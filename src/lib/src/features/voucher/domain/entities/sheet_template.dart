import 'enums/enums.dart';

/// 伝票フォーマットの定義（列構成のテンプレート）を表すドメインエンティティ。
///
/// 紙伝票（例:「寿」）1種類に対して1レコード存在し、`Header`（列定義）を
/// 配下に持つ。
class SheetTemplate {
  /// [SheetTemplate] を生成する。
  const SheetTemplate({
    required this.sheetTemplateId,
    required this.name,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 伝票フォーマットID。
  final String sheetTemplateId;

  /// フォーマット名（例:「寿」）。
  final String name;

  /// 論理削除状態。
  final RecordStatus status;

  /// 作成日時。
  final DateTime createdAt;

  /// 更新日時。
  final DateTime updatedAt;
}
