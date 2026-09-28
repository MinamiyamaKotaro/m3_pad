import '../entities/sheet_instance.dart';

/// [SheetInstance] に対する永続化・検索の契約のみを定義する抽象クラス。
abstract interface class SheetInstanceRepository {
  /// [instance] を1件永続化する。
  Future<void> insert(final SheetInstance instance);

  /// [sheetInstanceId] に一致する伝票インスタンスを1件取得する。
  Future<SheetInstance> findById(final String sheetInstanceId);

  /// [sheetTemplateId]・[businessDate] に一致する伝票インスタンスを取得する。
  ///
  /// 未作成の場合は`null`。
  Future<SheetInstance?> findByTemplateAndDate(
    final String sheetTemplateId,
    final DateTime businessDate,
  );
}
