import '../entities/staff_shift.dart';

/// [StaffShift] に対する永続化・検索の契約のみを定義する抽象クラス。
abstract interface class StaffShiftRepository {
  /// [shift] を1件永続化する。
  Future<void> insert(final StaffShift shift);

  /// [shift] の`staffId`・`startTime`・`endTime`・`drinkBack`を上書きする。
  Future<void> update(final StaffShift shift);

  /// [sheetInstanceId] に紐づくシフト一覧を`createdAt`昇順で取得する。
  Future<List<StaffShift>> findByInstanceId(final String sheetInstanceId);
}
