import '../entities/enums/enums.dart';
import '../entities/header.dart';

/// [Header] に対する永続化・検索・更新の契約のみを定義する抽象クラス。
abstract interface class HeaderRepository {
  /// [header] を1件永続化する。
  Future<void> insert(final Header header);

  /// [columnId] に一致する列を1件取得する。
  Future<Header> findById(final String columnId);

  /// [sheetTemplateId] に紐づく列一覧を`displayOrder`昇順で取得する。
  Future<List<Header>> findByTemplateId(final String sheetTemplateId);

  /// 複数列の表示順を1回のSQLで一括更新する。
  ///
  /// key=columnId, value=displayOrder。
  Future<void> updateDisplayOrders(
    final Map<String, int> displayOrderByColumnId,
  );

  /// [columnId] の論理削除状態を更新する。
  Future<void> updateStatus(final String columnId, final RecordStatus status);
}
