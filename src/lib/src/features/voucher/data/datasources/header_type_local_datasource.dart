import 'package:sqflite/sqflite.dart';

import '../../../../core/errors/record_not_found_exception.dart';
import '../models/header_type_model.dart';

/// `m_header_type`テーブルに対する実際のSQL実行を担うローカルデータ
/// ソース。
class HeaderTypeLocalDataSource {
  /// [HeaderTypeLocalDataSource] を生成する。
  const HeaderTypeLocalDataSource(this._db);

  final Database _db;

  /// 型一覧を全件取得する。
  Future<List<HeaderTypeModel>> findAll() async {
    final List<Map<String, Object?>> rows = await _db.query('m_header_type');
    return rows.map(HeaderTypeModel.fromMap).toList();
  }

  /// [typeId] に一致する型を1件取得する。
  Future<HeaderTypeModel> findById(final int typeId) async {
    final List<Map<String, Object?>> rows = await _db.query(
      'm_header_type',
      where: 'type_id = ?',
      whereArgs: <Object?>[typeId],
    );
    if (rows.isEmpty) {
      throw RecordNotFoundException(
        entityName: 'HeaderType',
        id: typeId.toString(),
      );
    }
    return HeaderTypeModel.fromMap(rows.first);
  }
}
