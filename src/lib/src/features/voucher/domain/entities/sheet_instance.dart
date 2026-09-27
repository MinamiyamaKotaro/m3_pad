import 'enums/enums.dart';

/// 営業日ごとに1枚作成される実際の伝票（インスタンス）を表すドメイン
/// エンティティ。紙伝票のPDF右上の「月／日」に相当する。
class SheetInstance {
  /// [SheetInstance] を生成する。
  const SheetInstance({
    required this.sheetInstanceId,
    required this.sheetTemplateId,
    required this.businessDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 伝票インスタンスID。
  final String sheetInstanceId;

  /// どのフォーマットを使ったか。
  final String sheetTemplateId;

  /// 営業日（日付のみ）。
  final DateTime businessDate;

  /// 論理削除状態。
  final RecordStatus status;

  /// 作成日時。
  final DateTime createdAt;

  /// 更新日時。
  final DateTime updatedAt;
}
