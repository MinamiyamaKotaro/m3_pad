import 'package:sqflite/sqflite.dart';

import '../../../../core/errors/record_not_found_exception.dart';
import '../../domain/entities/enums/enums.dart';
import '../models/staff_model.dart';

/// `m_staff`テーブルに対する実際のSQL実行を担うローカルデータソース。
class StaffLocalDataSource {
  /// [StaffLocalDataSource] を生成する。
  const StaffLocalDataSource(this._db);

  final Database _db;

  /// 新しい [StaffModel] を1件永続化する。
  Future<void> insert(final StaffModel model) async {
    await _db.insert('m_staff', model.toMap());
  }

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

  /// [name] に一致するスタッフを1件取得する。論理削除済みも含めて検索する。
  /// 存在しない場合は`null`。
  Future<StaffModel?> findByName(final String name) async {
    final List<Map<String, Object?>> rows = await _db.query(
      'm_staff',
      where: 'name = ?',
      whereArgs: <Object?>[name],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return StaffModel.fromMap(rows.first);
  }

  /// [staffId] の氏名を[name]に更新する。
  Future<void> updateName(final String staffId, final String name) async {
    final int affected = await _db.update(
      'm_staff',
      <String, Object?>{'name': name},
      where: 'staff_id = ? AND status = ?',
      whereArgs: <Object?>[staffId, RecordStatus.active.dbValue],
    );
    if (affected == 0) {
      throw RecordNotFoundException(entityName: 'Staff', id: staffId);
    }
  }

  /// [staffId] の論理削除状態を更新する。
  Future<void> updateStatus(
    final String staffId,
    final RecordStatus status,
  ) async {
    await _db.update(
      'm_staff',
      <String, Object?>{'status': status.dbValue},
      where: 'staff_id = ?',
      whereArgs: <Object?>[staffId],
    );
  }
}
