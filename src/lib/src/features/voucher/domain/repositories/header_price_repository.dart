import '../entities/header_price.dart';

/// [HeaderPrice] に対する永続化・検索・更新の契約のみを定義する抽象クラス。
abstract interface class HeaderPriceRepository {
  /// [headerPrice] を1件永続化する。
  Future<void> insert(final HeaderPrice headerPrice);

  /// [columnId] について、[targetDate] 時点で有効な単価を1件取得する。
  Future<HeaderPrice> findCurrentPrice(
    final String columnId,
    final DateTime targetDate,
  );

  /// 複数の [columnIds] について、[targetDate] 時点で有効な単価を一括取得
  /// する。単価未登録の列は結果に含まれない。
  Future<List<HeaderPrice>> findCurrentPrices(
    final List<String> columnIds,
    final DateTime targetDate,
  );

  /// [priceId] の適用終了日を [effectiveTo] に更新し、有効期間を終了させる。
  Future<void> closeCurrentPrice(
    final String priceId,
    final DateTime effectiveTo,
  );
}
