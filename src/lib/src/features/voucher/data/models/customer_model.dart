import '../../domain/entities/customer.dart';
import '../../domain/entities/enums/enums.dart';

/// [Customer] のデータ層表現。SQLiteの行と相互変換する`fromMap`/`toMap`を
/// 持つ。
class CustomerModel extends Customer {
  /// [CustomerModel] を生成する。
  const CustomerModel({
    required super.customerId,
    required super.name,
    required super.gender,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  /// SQLiteの行（`m_customer`テーブルの1行分）から [CustomerModel] を
  /// 生成する。
  factory CustomerModel.fromMap(final Map<String, Object?> map) =>
      CustomerModel(
        customerId: map['customer_id']! as String,
        name: map['name']! as String,
        gender: Gender.fromDbValue(map['gender']! as String),
        status: RecordStatus.fromDbValue(map['status']! as String),
        createdAt: DateTime.parse(map['created_at']! as String),
        updatedAt: DateTime.parse(map['updated_at']! as String),
      );

  /// SQLiteへ保存可能な`Map<String, Object?>`に変換する。
  Map<String, Object?> toMap() => <String, Object?>{
        'customer_id': customerId,
        'name': name,
        'gender': gender.dbValue,
        'status': status.dbValue,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
