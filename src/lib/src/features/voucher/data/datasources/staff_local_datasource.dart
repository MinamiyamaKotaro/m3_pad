import 'package:sqflite/sqflite.dart';

import '../../../../core/errors/record_not_found_exception.dart';
import '../../domain/entities/enums/enums.dart';
import '../models/staff_model.dart';

/// `m_staff`テーブルに対する実際のSQL実行を担うローカルデータソース。
class StaffLocalDataSource {
  /// [StaffLocalDataSource] を生成する。
  const StaffLocalDataSource(this._db);

  final Database _db;

  /// [staffId] に一致する有効なスタッフを1件取得する。
  Future<StaffModel> findById(final String staffId) async {
    final List<Map<String, Object?>> rows = await _db.query(
      'm_staff',
      where: 'staff_id = ? AND status = ?',
      whereArgs: <Object?>[staffId, RecordStatus.active.dbValue],
    );
    if (rows.isEmpty) {
      throw RecordNotFoundException(entityName: 'Staff', id: staffId);
    }
    return StaffModel.fromMap(rows.first);
  }

  /// 有効なスタッフ一覧を取得する。
  Future<List<StaffModel>> findAllActive() async {
    final List<Map<String, Object?>> rows = await _db.query(
      'm_staff',
      where: 'status = ?',
      whereArgs: <Object?>[RecordStatus.active.dbValue],
    );
    return rows.map(StaffModel.fromMap).toList();
  }
}
