import '../entities/sheet_row.dart';

/// [SheetRow] に対する永続化・検索の契約のみを定義する抽象クラス。
///
/// `totalAmount`はDBトリガーにより自動更新されるため、[update]の対象には
/// 含めない。
abstract interface class SheetRowRepository {
  /// [row] を1件永続化する。
  Future<void> insert(final SheetRow row);

  /// [row] の`customerId`・`staffId`・`paymentMethod`を上書きする。
  Future<void> update(final SheetRow row);

  /// [rowId] に一致する行を1件取得する。
  Future<SheetRow> findById(final String rowId);

  /// [sheetInstanceId] 内での現在の最大表示順を取得する。行が1件も
  /// 存在しない場合は0を返す。
  Future<int> findMaxRowOrder(final String sheetInstanceId);

  /// [sheetInstanceId] に紐づく行一覧を`rowOrder`昇順で取得する。
  Future<List<SheetRow>> findByInstanceId(final String sheetInstanceId);

  /// 複数の [sheetInstanceIds] に紐づく行を一括取得する。
  Future<List<SheetRow>> findByInstanceIds(
    final List<String> sheetInstanceIds,
  );

  /// [customerIds] のうち、[businessDate] より前の営業日の伝票に行が存在する
  /// （来店履歴がある）顧客IDを一括取得する。結果に含まれない顧客は、
  /// [businessDate] が初来店の新規客とみなす。
  Future<List<String>> findCustomerIdsVisitedBefore(
    final List<String> customerIds,
    final DateTime businessDate,
  );
}
