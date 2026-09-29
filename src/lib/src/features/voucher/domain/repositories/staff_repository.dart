import '../entities/enums/enums.dart';
import '../entities/staff.dart';

/// [Staff] に対する永続化・検索・更新の契約のみを定義する抽象クラス。
abstract interface class StaffRepository {
  /// [staff] を1件永続化する。
  Future<void> insert(final Staff staff);

  /// [staffId] に一致するスタッフを1件取得する。
  Future<Staff> findById(final String staffId);

  /// 有効なスタッフ一覧を取得する。
  Future<List<Staff>> findAllActive();

  /// [staffId] の氏名を[name]に更新する。
  Future<void> updateName(final String staffId, final String name);

  /// [staffId] の論理削除状態を更新する。
  Future<void> updateStatus(final String staffId, final RecordStatus status);
}
