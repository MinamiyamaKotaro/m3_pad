import 'package:sqflite/sqflite.dart';

import '../../../../core/errors/record_not_found_exception.dart';
import '../../domain/entities/enums/enums.dart';
import '../models/staff_shift_model.dart';

/// `t_staff_shift`テーブルに対する実際のSQL実行を担うローカルデータ
/// ソース。
class StaffShiftLocalDataSource {
  /// [StaffShiftLocalDataSource] を生成する。
  const StaffShiftLocalDataSource(this._db);

  final Database _db;

  /// 新しい [StaffShiftModel] を1件永続化する。
  Future<void> insert(final StaffShiftModel model) async {
    await _db.insert('t_staff_shift', model.toMap());
  }

  /// [model] の`staff_id`・`start_time`・`end_time`・`drink_back`を上書き
  /// する。
  Future<void> update(final StaffShiftModel model) async {
    final int affected = await _db.update(
      't_staff_shift',
      <String, Object?>{
        'staff_id': model.staffId,
        'start_time': model.startTime,
        'end_time': model.endTime,
        'drink_back': model.drinkBack,
        'updated_at': model.updatedAt.toIso8601String(),
      },
      where: 'shift_id = ? AND status = ?',
      whereArgs: <Object?>[model.shiftId, RecordStatus.active.dbValue],
    );
    if (affected == 0) {
      throw RecordNotFoundException(
        entityName: 'StaffShift',
        id: model.shiftId,
      );
    }
  }

  /// [sheetInstanceId] に紐づく有効なシフト一覧を`created_at`昇順で取得
  /// する。
  Future<List<StaffShiftModel>> findByInstanceId(
    final String sheetInstanceId,
  ) async {
    final List<Map<String, Object?>> rows = await _db.query(
      't_staff_shift',
      where: 'sheet_instance_id = ? AND status = ?',
      whereArgs: <Object?>[sheetInstanceId, RecordStatus.active.dbValue],
      orderBy: 'created_at ASC',
    );
    return rows.map(StaffShiftModel.fromMap).toList();
  }
}
