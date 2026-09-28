import 'enums/enums.dart';

/// 伝票の列（ヘッダー）に入力できる値の型を定義する固定小規模マスタの
/// ドメインエンティティ。`int`/`decimal`/`string`/`date`/`boolean`の5種類の
/// みを保持し、アプリ起動時にシードデータとして投入される。
class HeaderType {
  /// [HeaderType] を生成する。
  const HeaderType({
    required this.typeId,
    required this.typeName,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 型ID。DBの`AUTOINCREMENT`連番。
  final int typeId;

  /// 型名。
  final ColumnValueType typeName;

  /// 作成日時。
  final DateTime createdAt;

  /// 更新日時。
  final DateTime updatedAt;
}
