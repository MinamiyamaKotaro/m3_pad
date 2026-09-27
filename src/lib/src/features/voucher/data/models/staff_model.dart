import '../../domain/entities/enums/enums.dart';
import '../../domain/entities/staff.dart';

/// [Staff] のデータ層表現。SQLiteの行と相互変換する`fromMap`/`toMap`を
/// 持つ。
class StaffModel extends Staff {
  /// [StaffModel] を生成する。
  const StaffModel({
    required super.staffId,
    required super.name,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    super.staffCode,
  });

  /// SQLiteの行（`m_staff`テーブルの1行分）から [StaffModel] を生成する。
  factory StaffModel.fromMap(final Map<String, Object?> map) => StaffModel(
        staffId: map['staff_id']! as String,
        name: map['name']! as String,
        staffCode: map['staff_code'] as String?,
        status: RecordStatus.fromDbValue(map['status']! as String),
        createdAt: DateTime.parse(map['created_at']! as String),
        updatedAt: DateTime.parse(map['updated_at']! as String),
      );

  /// SQLiteへ保存可能な`Map<String, Object?>`に変換する。
  Map<String, Object?> toMap() => <String, Object?>{
        'staff_id': staffId,
        'name': name,
        'staff_code': staffCode,
        'status': status.dbValue,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
