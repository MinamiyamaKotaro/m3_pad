import '../../domain/entities/enums/enums.dart';
import '../../domain/entities/sheet_row.dart';

/// [SheetRow] のデータ層表現。SQLiteの行と相互変換する`fromMap`/`toMap`を
/// 持つ。
class SheetRowModel extends SheetRow {
  /// [SheetRowModel] を生成する。
  const SheetRowModel({
    required super.rowId,
    required super.sheetInstanceId,
    required super.rowOrder,
    required super.totalAmount,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    super.customerId,
    super.staffId,
    super.paymentMethod,
  });

  /// SQLiteの行（`t_row`テーブルの1行分）から [SheetRowModel] を生成する。
  factory SheetRowModel.fromMap(final Map<String, Object?> map) {
    final String? paymentMethod = map['payment_method'] as String?;
    return SheetRowModel(
      rowId: map['row_id']! as String,
      sheetInstanceId: map['sheet_instance_id']! as String,
      customerId: map['customer_id'] as String?,
      staffId: map['staff_id'] as String?,
      rowOrder: map['row_order']! as int,
      totalAmount: map['total_amount']! as int,
      paymentMethod: paymentMethod == null
          ? null
          : PaymentMethod.fromDbValue(paymentMethod),
      status: RecordStatus.fromDbValue(map['status']! as String),
      createdAt: DateTime.parse(map['created_at']! as String),
      updatedAt: DateTime.parse(map['updated_at']! as String),
    );
  }

  /// SQLiteへ保存可能な`Map<String, Object?>`に変換する。
  Map<String, Object?> toMap() => <String, Object?>{
        'row_id': rowId,
        'sheet_instance_id': sheetInstanceId,
        'customer_id': customerId,
        'staff_id': staffId,
        'row_order': rowOrder,
        'total_amount': totalAmount,
        'payment_method': paymentMethod?.dbValue,
        'status': status.dbValue,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
