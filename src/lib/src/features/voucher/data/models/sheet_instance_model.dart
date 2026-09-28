import '../../../../core/utils/sqlite_date.dart';
import '../../domain/entities/enums/enums.dart';
import '../../domain/entities/sheet_instance.dart';

/// [SheetInstance] のデータ層表現。SQLiteの行と相互変換する`fromMap`/
/// `toMap`を持つ。
class SheetInstanceModel extends SheetInstance {
  /// [SheetInstanceModel] を生成する。
  const SheetInstanceModel({
    required super.sheetInstanceId,
    required super.sheetTemplateId,
    required super.businessDate,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  /// SQLiteの行（`t_sheet_instance`テーブルの1行分）から
  /// [SheetInstanceModel] を生成する。
  factory SheetInstanceModel.fromMap(final Map<String, Object?> map) =>
      SheetInstanceModel(
        sheetInstanceId: map['sheet_instance_id']! as String,
        sheetTemplateId: map['sheet_template_id']! as String,
        businessDate: parseDateOnly(map['business_date']! as String),
        status: RecordStatus.fromDbValue(map['status']! as String),
        createdAt: DateTime.parse(map['created_at']! as String),
        updatedAt: DateTime.parse(map['updated_at']! as String),
      );

  /// SQLiteへ保存可能な`Map<String, Object?>`に変換する。
  Map<String, Object?> toMap() => <String, Object?>{
        'sheet_instance_id': sheetInstanceId,
        'sheet_template_id': sheetTemplateId,
        'business_date': formatDateOnly(businessDate),
        'status': status.dbValue,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
