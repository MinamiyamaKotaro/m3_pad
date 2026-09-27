import '../../domain/entities/sheet_cell.dart';
import '../../domain/repositories/sheet_cell_repository.dart';
import '../datasources/sheet_cell_local_datasource.dart';
import '../models/sheet_cell_model.dart';

/// [SheetCellRepository]（domain層インターフェース）の実装クラス。
/// [SheetCellLocalDataSource]へ処理を委譲する。
class SheetCellRepositoryImpl implements SheetCellRepository {
  /// [SheetCellRepositoryImpl] を生成する。
  const SheetCellRepositoryImpl(this._dataSource);

  final SheetCellLocalDataSource _dataSource;

  @override
  Future<SheetCell?> findByRowAndColumn(
    final String rowId,
    final String columnId,
  ) async {
    final SheetCell? result = await _dataSource.findByRowAndColumn(
      rowId,
      columnId,
    );
    return result;
  }

  @override
  Future<void> insert(final SheetCell cell) async {
    final SheetCellModel model = _toModel(cell);
    await _dataSource.insert(model);
  }

  @override
  Future<void> update(final SheetCell cell) async {
    final SheetCellModel model = _toModel(cell);
    await _dataSource.update(model);
  }

  @override
  Future<List<SheetCell>> findByRowId(final String rowId) async {
    final List<SheetCell> result = await _dataSource.findByRowId(rowId);
    return result;
  }

  @override
  Future<List<SheetCell>> findByRowIds(final List<String> rowIds) async {
    final List<SheetCell> result = await _dataSource.findByRowIds(rowIds);
    return result;
  }

  SheetCellModel _toModel(final SheetCell cell) => SheetCellModel(
        cellId: cell.cellId,
        rowId: cell.rowId,
        columnId: cell.columnId,
        content: cell.content,
        quantity: cell.quantity,
        unitPriceApplied: cell.unitPriceApplied,
        amount: cell.amount,
        createdAt: cell.createdAt,
        updatedAt: cell.updatedAt,
      );
}
