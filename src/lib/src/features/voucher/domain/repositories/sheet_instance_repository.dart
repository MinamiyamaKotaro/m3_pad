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

  /// [sheetTemplateId] に紐づき、[from]〜[to]（両端含む）の営業日を持つ
  /// 伝票インスタンス一覧を`businessDate`昇順で取得する。
  Future<List<SheetInstance>> findByTemplateIdAndDateRange(
    final String sheetTemplateId,
    final DateTime from,
    final DateTime to,
  );
}
