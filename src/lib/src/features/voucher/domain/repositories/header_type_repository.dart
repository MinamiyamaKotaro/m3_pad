import '../entities/header_type.dart';

/// [HeaderType] の検索の契約のみを定義する抽象クラス。
abstract interface class HeaderTypeRepository {
  /// 型一覧を全件取得する（固定5件）。
  Future<List<HeaderType>> findAll();

  /// [typeId] に一致する型を1件取得する。
  Future<HeaderType> findById(final int typeId);
}
