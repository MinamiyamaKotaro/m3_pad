import '../../domain/entities/enums/enums.dart';
import '../../domain/entities/sheet_template.dart';

/// [SheetTemplate] のデータ層表現。SQLiteの行と相互変換する`fromMap`/
/// `toMap`を持つ。
class SheetTemplateModel extends SheetTemplate {
  /// [SheetTemplateModel] を生成する。
  const SheetTemplateModel({
    required super.sheetTemplateId,
    required super.name,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  /// SQLiteの行（`m_sheet_template`テーブルの1行分）から
  /// [SheetTemplateModel] を生成する。
  factory SheetTemplateModel.fromMap(final Map<String, Object?> map) =>
      SheetTemplateModel(
        sheetTemplateId: map['sheet_template_id']! as String,
        name: map['name']! as String,
        status: RecordStatus.fromDbValue(map['status']! as String),
        createdAt: DateTime.parse(map['created_at']! as String),
        updatedAt: DateTime.parse(map['updated_at']! as String),
      );

  /// SQLiteへ保存可能な`Map<String, Object?>`に変換する。
  Map<String, Object?> toMap() => <String, Object?>{
        'sheet_template_id': sheetTemplateId,
        'name': name,
        'status': status.dbValue,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
