import 'package:sqflite/sqflite.dart';

import '../../../../core/errors/record_not_found_exception.dart';
import '../../domain/entities/enums/enums.dart';
import '../models/header_model.dart';

/// `m_header`テーブルに対する実際のSQL実行を担うローカルデータソース。
class HeaderLocalDataSource {
  /// [HeaderLocalDataSource] を生成する。
  const HeaderLocalDataSource(this._db);

  final Database _db;

  /// 新しい [HeaderModel] を1件永続化する。
  Future<void> insert(final HeaderModel model) async {
    await _db.insert('m_header', model.toMap());
  }

  /// [columnId] に一致する有効な列を1件取得する。
  Future<HeaderModel> findById(final String columnId) async {
    final List<Map<String, Object?>> rows = await _db.query(
      'm_header',
      where: 'column_id = ? AND status = ?',
      whereArgs: <Object?>[columnId, RecordStatus.active.dbValue],
    );
    if (rows.isEmpty) {
      throw RecordNotFoundException(entityName: 'Header', id: columnId);
    }
    return HeaderModel.fromMap(rows.first);
  }

  /// [sheetTemplateId] に紐づく有効な列一覧を`display_order`昇順で取得する。
  Future<List<HeaderModel>> findByTemplateId(
    final String sheetTemplateId,
  ) async {
    final List<Map<String, Object?>> rows = await _db.query(
      'm_header',
      where: 'sheet_template_id = ? AND status = ?',
      whereArgs: <Object?>[sheetTemplateId, RecordStatus.active.dbValue],
      orderBy: 'display_order ASC',
    );
    return rows.map(HeaderModel.fromMap).toList();
  }

  /// [model]の`name`・`category`・`is_visible`を上書きする。
  Future<void> update(final HeaderModel model) async {
    final int affected = await _db.update(
      'm_header',
      <String, Object?>{
        'name': model.name,
        'category': model.category.dbValue,
        'is_visible': model.isVisible ? 1 : 0,
        'updated_at': model.updatedAt.toIso8601String(),
      },
      where: 'column_id = ? AND status = ?',
      whereArgs: <Object?>[model.columnId, RecordStatus.active.dbValue],
    );
    if (affected == 0) {
      throw RecordNotFoundException(
        entityName: 'Header',
        id: model.columnId,
      );
    }
  }

  /// 複数列の表示順を1回のトランザクションで一括更新する。
  Future<void> updateDisplayOrders(
    final Map<String, int> displayOrderByColumnId,
  ) async {
    await _db.transaction((final Transaction txn) async {
      for (final MapEntry<String, int> entry
          in displayOrderByColumnId.entries) {
        await txn.update(
          'm_header',
          <String, Object?>{'display_order': entry.value},
          where: 'column_id = ?',
          whereArgs: <Object?>[entry.key],
        );
      }
    });
  }

  /// [columnId] の論理削除状態を更新する。
  Future<void> updateStatus(
    final String columnId,
    final RecordStatus status,
  ) async {
    await _db.update(
      'm_header',
      <String, Object?>{'status': status.dbValue},
      where: 'column_id = ?',
      whereArgs: <Object?>[columnId],
    );
  }
}
