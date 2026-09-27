import '../entities/sheet_cell.dart';

/// [SheetCell] に対する永続化・検索・更新の契約のみを定義する抽象クラス。
abstract interface class SheetCellRepository {
  /// [rowId]・[columnId] の組に一致するセルを1件取得する。未入力の場合は
  /// `null`。
  Future<SheetCell?> findByRowAndColumn(
    final String rowId,
    final String columnId,
  );

  /// [cell] を1件永続化する。
  Future<void> insert(final SheetCell cell);

  /// [cell] の値を更新する。
  Future<void> update(final SheetCell cell);

  /// [rowId] に紐づくセルを全件取得する。
  Future<List<SheetCell>> findByRowId(final String rowId);

  /// 複数の [rowIds] に紐づくセルを一括取得する。
  Future<List<SheetCell>> findByRowIds(final List<String> rowIds);
}
