import '../../domain/entities/sheet_row.dart';
import '../../domain/repositories/sheet_row_repository.dart';
import '../datasources/sheet_row_local_datasource.dart';
import '../models/sheet_row_model.dart';

/// [SheetRowRepository]（domain層インターフェース）の実装クラス。
/// [SheetRowLocalDataSource]へ処理を委譲する。
class SheetRowRepositoryImpl implements SheetRowRepository {
  /// [SheetRowRepositoryImpl] を生成する。
  const SheetRowRepositoryImpl(this._dataSource);

  final SheetRowLocalDataSource _dataSource;

  @override
  Future<void> insert(final SheetRow row) async {
    final SheetRowModel model = _toModel(row);
    await _dataSource.insert(model);
  }

  @override
  Future<void> update(final SheetRow row) async {
    final SheetRowModel model = _toModel(row);
    await _dataSource.update(model);
  }

  @override
  Future<SheetRow> findById(final String rowId) async {
    final SheetRow result = await _dataSource.findById(rowId);
    return result;
  }

  @override
  Future<int> findMaxRowOrder(final String sheetInstanceId) async {
    final int result = await _dataSource.findMaxRowOrder(sheetInstanceId);
    return result;
  }

  @override
  Future<List<SheetRow>> findByInstanceId(
    final String sheetInstanceId,
  ) async {
    final List<SheetRow> result = await _dataSource.findByInstanceId(
      sheetInstanceId,
    );
    return result;
  }

  @override
  Future<List<SheetRow>> findByInstanceIds(
    final List<String> sheetInstanceIds,
  ) async {
    final List<SheetRow> result = await _dataSource.findByInstanceIds(
      sheetInstanceIds,
    );
    return result;
  }

  SheetRowModel _toModel(final SheetRow row) => SheetRowModel(
        rowId: row.rowId,
        sheetInstanceId: row.sheetInstanceId,
        customerId: row.customerId,
        staffId: row.staffId,
        rowOrder: row.rowOrder,
        totalAmount: row.totalAmount,
        paymentMethod: row.paymentMethod,
        status: row.status,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );
}
