import '../entities/sheet_template.dart';

/// [SheetTemplate] に対する永続化・検索の契約のみを定義する抽象クラス。
abstract interface class SheetTemplateRepository {
  /// [template] を1件永続化する。
  Future<void> insert(final SheetTemplate template);

  /// [sheetTemplateId] に一致する伝票フォーマットを1件取得する。
  Future<SheetTemplate> findById(final String sheetTemplateId);

  /// 有効な伝票フォーマット一覧を取得する。
  Future<List<SheetTemplate>> findAllActive();
}
