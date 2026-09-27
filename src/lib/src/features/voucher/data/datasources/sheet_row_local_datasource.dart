import 'package:sqflite/sqflite.dart';

import '../../../../core/errors/record_not_found_exception.dart';
import '../../domain/entities/enums/enums.dart';
import '../models/sheet_row_model.dart';

/// `t_row`テーブルに対する実際のSQL実行を担うローカルデータソース。
///
/// `total_amount`はDBトリガーにより自動更新されるため、`update`の対象には
/// 含めない。
class SheetRowLocalDataSource {
  /// [SheetRowLocalDataSource] を生成する。
  const SheetRowLocalDataSource(this._db);

  final Database _db;

  /// 新しい [SheetRowModel] を1件永続化する。
  Future<void> insert(final SheetRowModel model) async {
    await _db.insert('t_row', model.toMap());
  }

  /// [model] の`customer_id`・`staff_id`・`payment_method`を上書きする。
  Future<void> update(final SheetRowModel model) async {
    final int affected = await _db.update(
      't_row',
      <String, Object?>{
        'customer_id': model.customerId,
        'staff_id': model.staffId,
        'payment_method': model.paymentMethod?.dbValue,
        'updated_at': model.updatedAt.toIso8601String(),
      },
      where: 'row_id = ? AND status = ?',
      whereArgs: <Object?>[model.rowId, RecordStatus.active.dbValue],
    );
    if (affected == 0) {
      throw RecordNotFoundException(entityName: 'SheetRow', id: model.rowId);
    }
  }

  /// [rowId] に一致する有効な行を1件取得する。
  Future<SheetRowModel> findById(final String rowId) async {
    final List<Map<String, Object?>> rows = await _db.query(
      't_row',
      where: 'row_id = ? AND status = ?',
      whereArgs: <Object?>[rowId, RecordStatus.active.dbValue],
    );
    if (rows.isEmpty) {
      throw RecordNotFoundException(entityName: 'SheetRow', id: rowId);
    }
    return SheetRowModel.fromMap(rows.first);
  }

  /// [sheetInstanceId] 内での現在の最大表示順を取得する。
  Future<int> findMaxRowOrder(final String sheetInstanceId) async {
    final List<Map<String, Object?>> rows = await _db.rawQuery(
      '''
      SELECT COALESCE(MAX(row_order), 0) AS max_row_order
      FROM t_row WHERE sheet_instance_id = ? AND status = ?
      ''',
      <Object?>[sheetInstanceId, RecordStatus.active.dbValue],
    );
    return rows.first['max_row_order']! as int;
  }

  /// [sheetInstanceId] に紐づく有効な行一覧を`row_order`昇順で取得する。
  Future<List<SheetRowModel>> findByInstanceId(
    final String sheetInstanceId,
  ) async {
    final List<Map<String, Object?>> rows = await _db.query(
      't_row',
      where: 'sheet_instance_id = ? AND status = ?',
      whereArgs: <Object?>[sheetInstanceId, RecordStatus.active.dbValue],
      orderBy: 'row_order ASC',
    );
    return rows.map(SheetRowModel.fromMap).toList();
  }
}
