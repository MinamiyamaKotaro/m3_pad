import '../../domain/entities/sheet_cell.dart';

/// [SheetCell] のデータ層表現。SQLiteの行と相互変換する`fromMap`/`toMap`を
/// 持つ。
class SheetCellModel extends SheetCell {
  /// [SheetCellModel] を生成する。
  const SheetCellModel({
    required super.cellId,
    required super.rowId,
    required super.columnId,
    required super.createdAt,
    required super.updatedAt,
    super.content,
    super.quantity,
    super.unitPriceApplied,
    super.amount,
  });

  /// SQLiteの行（`t_cell`テーブルの1行分）から [SheetCellModel] を生成する。
  factory SheetCellModel.fromMap(final Map<String, Object?> map) =>
      SheetCellModel(
        cellId: map['cell_id']! as String,
        rowId: map['row_id']! as String,
        columnId: map['column_id']! as String,
        content: map['content'] as String?,
        quantity: map['quantity'] as int?,
        unitPriceApplied: map['unit_price_applied'] as int?,
        amount: map['amount'] as int?,
        createdAt: DateTime.parse(map['created_at']! as String),
        updatedAt: DateTime.parse(map['updated_at']! as String),
      );

  /// SQLiteへ保存可能な`Map<String, Object?>`に変換する。
  Map<String, Object?> toMap() => <String, Object?>{
        'cell_id': cellId,
        'row_id': rowId,
        'column_id': columnId,
        'content': content,
        'quantity': quantity,
        'unit_price_applied': unitPriceApplied,
        'amount': amount,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
