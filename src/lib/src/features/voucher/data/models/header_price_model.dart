import '../../../../core/utils/sqlite_date.dart';
import '../../domain/entities/header_price.dart';

/// [HeaderPrice] のデータ層表現。SQLiteの行と相互変換する`fromMap`/`toMap`
/// を持つ。
class HeaderPriceModel extends HeaderPrice {
  /// [HeaderPriceModel] を生成する。
  const HeaderPriceModel({
    required super.priceId,
    required super.columnId,
    required super.price,
    required super.effectiveFrom,
    required super.createdAt,
    required super.updatedAt,
    super.effectiveTo,
  });

  /// SQLiteの行（`m_header_price`テーブルの1行分）から [HeaderPriceModel] を
  /// 生成する。
  factory HeaderPriceModel.fromMap(final Map<String, Object?> map) {
    final String? effectiveTo = map['effective_to'] as String?;
    return HeaderPriceModel(
      priceId: map['price_id']! as String,
      columnId: map['column_id']! as String,
      price: map['price']! as int,
      effectiveFrom: parseDateOnly(map['effective_from']! as String),
      effectiveTo: effectiveTo == null ? null : parseDateOnly(effectiveTo),
      createdAt: DateTime.parse(map['created_at']! as String),
      updatedAt: DateTime.parse(map['updated_at']! as String),
    );
  }

  /// SQLiteへ保存可能な`Map<String, Object?>`に変換する。
  Map<String, Object?> toMap() => <String, Object?>{
        'price_id': priceId,
        'column_id': columnId,
        'price': price,
        'effective_from': formatDateOnly(effectiveFrom),
        'effective_to':
            effectiveTo == null ? null : formatDateOnly(effectiveTo!),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
