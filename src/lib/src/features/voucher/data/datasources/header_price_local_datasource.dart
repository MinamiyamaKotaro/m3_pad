import 'package:sqflite/sqflite.dart';

import '../../../../core/errors/record_not_found_exception.dart';
import '../../../../core/utils/sqlite_date.dart';
import '../models/header_price_model.dart';

/// `m_header_price`テーブルに対する実際のSQL実行を担うローカルデータ
/// ソース。
class HeaderPriceLocalDataSource {
  /// [HeaderPriceLocalDataSource] を生成する。
  const HeaderPriceLocalDataSource(this._db);

  final Database _db;

  /// 新しい [HeaderPriceModel] を1件永続化する。
  Future<void> insert(final HeaderPriceModel model) async {
    await _db.insert('m_header_price', model.toMap());
  }

  /// [columnId] について、[targetDate] 時点で有効な単価を1件取得する。
  Future<HeaderPriceModel> findCurrentPrice(
    final String columnId,
    final DateTime targetDate,
  ) async {
    final String target = formatDateOnly(targetDate);
    final List<Map<String, Object?>> rows = await _db.rawQuery(
      '''
      SELECT * FROM m_header_price
      WHERE column_id = ?
        AND effective_from <= ?
        AND (effective_to IS NULL OR effective_to > ?)
      ORDER BY effective_from DESC LIMIT 1
      ''',
      <Object?>[columnId, target, target],
    );
    if (rows.isEmpty) {
      throw RecordNotFoundException(entityName: 'HeaderPrice', id: columnId);
    }
    return HeaderPriceModel.fromMap(rows.first);
  }

  /// [priceId] の適用終了日を [effectiveTo] に更新する。
  Future<void> closeCurrentPrice(
    final String priceId,
    final DateTime effectiveTo,
  ) async {
    await _db.update(
      'm_header_price',
      <String, Object?>{
        'effective_to': formatDateOnly(effectiveTo),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'price_id = ?',
      whereArgs: <Object?>[priceId],
    );
  }
}
