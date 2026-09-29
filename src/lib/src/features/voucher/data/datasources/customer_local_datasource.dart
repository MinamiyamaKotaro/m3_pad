import 'package:sqflite/sqflite.dart';

import '../../../../core/errors/record_not_found_exception.dart';
import '../../domain/entities/enums/enums.dart';
import '../models/customer_model.dart';

/// `m_customer`テーブルに対する実際のSQL実行を担うローカルデータソース。
class CustomerLocalDataSource {
  /// [CustomerLocalDataSource] を生成する。
  const CustomerLocalDataSource(this._db);

  final Database _db;

  /// 新しい [CustomerModel] を1件永続化する。
  Future<void> insert(final CustomerModel model) async {
    await _db.insert('m_customer', model.toMap());
  }

  /// [customerId] に一致する有効な顧客を1件取得する。
  Future<CustomerModel> findById(final String customerId) async {
    final List<Map<String, Object?>> rows = await _db.query(
      'm_customer',
      where: 'customer_id = ? AND status = ?',
      whereArgs: <Object?>[customerId, RecordStatus.active.dbValue],
    );
    if (rows.isEmpty) {
      throw RecordNotFoundException(entityName: 'Customer', id: customerId);
    }
    return CustomerModel.fromMap(rows.first);
  }

  /// 複数の [customerIds] に紐づく有効な顧客を一括取得する。
  Future<List<CustomerModel>> findByIds(
    final List<String> customerIds,
  ) async {
    if (customerIds.isEmpty) {
      return <CustomerModel>[];
    }
    final String placeholders = List<String>.filled(
      customerIds.length,
      '?',
    ).join(', ');
    final List<Map<String, Object?>> rows = await _db.rawQuery(
      'SELECT * FROM m_customer WHERE customer_id IN ($placeholders) '
      'AND status = ?',
      <Object?>[...customerIds, RecordStatus.active.dbValue],
    );
    return rows.map(CustomerModel.fromMap).toList();
  }

  /// [name] に一致する有効な顧客を1件取得する。存在しない場合は`null`。
  Future<CustomerModel?> findByName(final String name) async {
    final List<Map<String, Object?>> rows = await _db.query(
      'm_customer',
      where: 'name = ? AND status = ?',
      whereArgs: <Object?>[name, RecordStatus.active.dbValue],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return CustomerModel.fromMap(rows.first);
  }
}
