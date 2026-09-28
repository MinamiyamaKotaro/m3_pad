import '../../domain/entities/enums/enums.dart';
import '../../domain/entities/staff_shift.dart';

/// [StaffShift] のデータ層表現。SQLiteの行と相互変換する`fromMap`/`toMap`
/// を持つ。
class StaffShiftModel extends StaffShift {
  /// [StaffShiftModel] を生成する。
  const StaffShiftModel({
    required super.shiftId,
    required super.sheetInstanceId,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    super.staffId,
    super.startTime,
    super.endTime,
    super.drinkBack,
  });

  /// SQLiteの行（`t_staff_shift`テーブルの1行分）から [StaffShiftModel] を
  /// 生成する。
  factory StaffShiftModel.fromMap(final Map<String, Object?> map) =>
      StaffShiftModel(
        shiftId: map['shift_id']! as String,
        sheetInstanceId: map['sheet_instance_id']! as String,
        staffId: map['staff_id'] as String?,
        startTime: map['start_time'] as String?,
        endTime: map['end_time'] as String?,
        drinkBack: map['drink_back'] as String?,
        status: RecordStatus.fromDbValue(map['status']! as String),
        createdAt: DateTime.parse(map['created_at']! as String),
        updatedAt: DateTime.parse(map['updated_at']! as String),
      );

  /// SQLiteへ保存可能な`Map<String, Object?>`に変換する。
  Map<String, Object?> toMap() => <String, Object?>{
        'shift_id': shiftId,
        'sheet_instance_id': sheetInstanceId,
        'staff_id': staffId,
        'start_time': startTime,
        'end_time': endTime,
        'drink_back': drinkBack,
        'status': status.dbValue,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
