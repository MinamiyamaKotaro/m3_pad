import '../../domain/entities/enums/enums.dart';
import '../../domain/entities/header_type.dart';

/// [HeaderType] のデータ層表現。SQLiteの行と相互変換する`fromMap`/`toMap`
/// を持つ。
class HeaderTypeModel extends HeaderType {
  /// [HeaderTypeModel] を生成する。
  const HeaderTypeModel({
    required super.typeId,
    required super.typeName,
    required super.createdAt,
    required super.updatedAt,
  });

  /// SQLiteの行（`m_header_type`テーブルの1行分）から [HeaderTypeModel] を
  /// 生成する。
  factory HeaderTypeModel.fromMap(final Map<String, Object?> map) =>
      HeaderTypeModel(
        typeId: map['type_id']! as int,
        typeName: ColumnValueType.fromDbValue(map['type_name']! as String),
        createdAt: DateTime.parse(map['created_at']! as String),
        updatedAt: DateTime.parse(map['updated_at']! as String),
      );

  /// SQLiteへ保存可能な`Map<String, Object?>`に変換する。
  Map<String, Object?> toMap() => <String, Object?>{
        'type_id': typeId,
        'type_name': typeName.dbValue,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
