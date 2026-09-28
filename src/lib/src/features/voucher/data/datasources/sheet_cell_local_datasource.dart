import 'package:sqflite/sqflite.dart';

import '../models/sheet_cell_model.dart';

/// `t_cell`テーブルに対する実際のSQL実行を担うローカルデータソース。
class SheetCellLocalDataSource {
  /// [SheetCellLocalDataSource] を生成する。
  const SheetCellLocalDataSource(this._db);

  final Database _db;

  /// [rowId]・[columnId] の組に一致するセルを1件取得する。未入力の場合は
  /// `null`。
  Future<SheetCellModel?> findByRowAndColumn(
    final String rowId,
    final String columnId,
  ) async {
    final List<Map<String, Object?>> rows = await _db.query(
      't_cell',
      where: 'row_id = ? AND column_id = ?',
      whereArgs: <Object?>[rowId, columnId],
    );
    if (rows.isEmpty) {
      return null;
    }
    return SheetCellModel.fromMap(rows.first);
  }

  /// 新しい [SheetCellModel] を1件永続化する。
  Future<void> insert(final SheetCellModel model) async {
    await _db.insert('t_cell', model.toMap());
  }

  /// 既存の [SheetCellModel] の値を更新する。
  Future<void> update(final SheetCellModel model) async {
    await _db.update(
      't_cell',
      <String, Object?>{
        'content': model.content,
        'quantity': model.quantity,
        'unit_price_applied': model.unitPriceApplied,
        'amount': model.amount,
        'updated_at': model.updatedAt.toIso8601String(),
      },
      where: 'cell_id = ?',
      whereArgs: <Object?>[model.cellId],
    );
  }

  /// [rowId] に紐づくセルを全件取得する。
  Future<List<SheetCellModel>> findByRowId(final String rowId) async {
    final List<Map<String, Object?>> rows = await _db.query(
      't_cell',
      where: 'row_id = ?',
      whereArgs: <Object?>[rowId],
    );
    return rows.map(SheetCellModel.fromMap).toList();
  }

  /// 複数の [rowIds] に紐づくセルを一括取得する。
  Future<List<SheetCellModel>> findByRowIds(
    final List<String> rowIds,
  ) async {
    if (rowIds.isEmpty) {
      return <SheetCellModel>[];
    }
    final String placeholders = List<String>.filled(
      rowIds.length,
      '?',
    ).join(', ');
    final List<Map<String, Object?>> rows = await _db.rawQuery(
      'SELECT * FROM t_cell WHERE row_id IN ($placeholders)',
      rowIds,
    );
    return rows.map(SheetCellModel.fromMap).toList();
  }
}
