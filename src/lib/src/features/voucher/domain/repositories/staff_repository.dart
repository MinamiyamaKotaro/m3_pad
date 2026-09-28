import '../entities/staff.dart';

/// [Staff] の検索の契約のみを定義する抽象クラス。
abstract interface class StaffRepository {
  /// [staffId] に一致するスタッフを1件取得する。
  Future<Staff> findById(final String staffId);

  /// 有効なスタッフ一覧を取得する。
  Future<List<Staff>> findAllActive();
}
