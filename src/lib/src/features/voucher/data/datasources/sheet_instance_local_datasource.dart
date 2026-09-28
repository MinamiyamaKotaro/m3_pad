import 'package:sqflite/sqflite.dart';

import '../../../../core/errors/record_not_found_exception.dart';
import '../../../../core/utils/sqlite_date.dart';
import '../../domain/entities/enums/enums.dart';
import '../models/sheet_instance_model.dart';

/// `t_sheet_instance`テーブルに対する実際のSQL実行を担うローカルデータ
/// ソース。
class SheetInstanceLocalDataSource {
  /// [SheetInstanceLocalDataSource] を生成する。
  const SheetInstanceLocalDataSource(this._db);

  final Database _db;

  /// 新しい [SheetInstanceModel] を1件永続化する。
  Future<void> insert(final SheetInstanceModel model) async {
    await _db.insert('t_sheet_instance', model.toMap());
  }

  /// [sheetInstanceId] に一致する有効な伝票インスタンスを1件取得する。
  Future<SheetInstanceModel> findById(final String sheetInstanceId) async {
    final List<Map<String, Object?>> rows = await _db.query(
      't_sheet_instance',
      where: 'sheet_instance_id = ? AND status = ?',
      whereArgs: <Object?>[sheetInstanceId, RecordStatus.active.dbValue],
    );
    if (rows.isEmpty) {
      throw RecordNotFoundException(
        entityName: 'SheetInstance',
        id: sheetInstanceId,
      );
    }
    return SheetInstanceModel.fromMap(rows.first);
  }

  /// [sheetTemplateId]・[businessDate] に一致する有効な伝票インスタンスを
  /// 取得する。未作成の場合は`null`。
  Future<SheetInstanceModel?> findByTemplateAndDate(
    final String sheetTemplateId,
    final DateTime businessDate,
  ) async {
    final List<Map<String, Object?>> rows = await _db.query(
      't_sheet_instance',
      where: 'sheet_template_id = ? AND business_date = ? AND status = ?',
      whereArgs: <Object?>[
        sheetTemplateId,
        formatDateOnly(businessDate),
        RecordStatus.active.dbValue,
      ],
    );
    if (rows.isEmpty) {
      return null;
    }
    return SheetInstanceModel.fromMap(rows.first);
  }
}
