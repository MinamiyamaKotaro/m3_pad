import '../../domain/entities/enums/enums.dart';
import '../../domain/entities/header.dart';

/// [Header] のデータ層表現。SQLiteの行と相互変換する`fromMap`/`toMap`を
/// 持つ。
class HeaderModel extends Header {
  /// [HeaderModel] を生成する。
  const HeaderModel({
    required super.columnId,
    required super.sheetTemplateId,
    required super.typeId,
    required super.name,
    required super.displayOrder,
    required super.isPriced,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  /// SQLiteの行（`m_header`テーブルの1行分）から [HeaderModel] を生成する。
  factory HeaderModel.fromMap(final Map<String, Object?> map) => HeaderModel(
        columnId: map['column_id']! as String,
        sheetTemplateId: map['sheet_template_id']! as String,
        typeId: map['type_id']! as int,
        name: map['name']! as String,
        displayOrder: map['display_order']! as int,
        isPriced: (map['is_priced']! as int) == 1,
        status: RecordStatus.fromDbValue(map['status']! as String),
        createdAt: DateTime.parse(map['created_at']! as String),
        updatedAt: DateTime.parse(map['updated_at']! as String),
      );

  /// SQLiteへ保存可能な`Map<String, Object?>`に変換する。
  Map<String, Object?> toMap() => <String, Object?>{
        'column_id': columnId,
        'sheet_template_id': sheetTemplateId,
        'type_id': typeId,
        'name': name,
        'display_order': displayOrder,
        'is_priced': isPriced ? 1 : 0,
        'status': status.dbValue,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
