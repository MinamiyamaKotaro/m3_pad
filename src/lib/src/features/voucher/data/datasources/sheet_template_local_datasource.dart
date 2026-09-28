import 'package:sqflite/sqflite.dart';

import '../../../../core/errors/record_not_found_exception.dart';
import '../../domain/entities/enums/enums.dart';
import '../models/sheet_template_model.dart';

/// `m_sheet_template`テーブルに対する実際のSQL実行を担うローカルデータ
/// ソース。
class SheetTemplateLocalDataSource {
  /// [SheetTemplateLocalDataSource] を生成する。
  const SheetTemplateLocalDataSource(this._db);

  final Database _db;

  /// 新しい [SheetTemplateModel] を1件永続化する。
  Future<void> insert(final SheetTemplateModel model) async {
    await _db.insert('m_sheet_template', model.toMap());
  }

  /// [sheetTemplateId] に一致する有効な伝票フォーマットを1件取得する。
  Future<SheetTemplateModel> findById(final String sheetTemplateId) async {
    final List<Map<String, Object?>> rows = await _db.query(
      'm_sheet_template',
      where: 'sheet_template_id = ? AND status = ?',
      whereArgs: <Object?>[sheetTemplateId, RecordStatus.active.dbValue],
    );
    if (rows.isEmpty) {
      throw RecordNotFoundException(
        entityName: 'SheetTemplate',
        id: sheetTemplateId,
      );
    }
    return SheetTemplateModel.fromMap(rows.first);
  }

  /// 有効な伝票フォーマット一覧を取得する。
  Future<List<SheetTemplateModel>> findAllActive() async {
    final List<Map<String, Object?>> rows = await _db.query(
      'm_sheet_template',
      where: 'status = ?',
      whereArgs: <Object?>[RecordStatus.active.dbValue],
    );
    return rows.map(SheetTemplateModel.fromMap).toList();
  }
}
