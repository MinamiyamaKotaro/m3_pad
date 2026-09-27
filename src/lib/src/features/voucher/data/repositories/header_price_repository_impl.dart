import '../../domain/entities/header_price.dart';
import '../../domain/repositories/header_price_repository.dart';
import '../datasources/header_price_local_datasource.dart';
import '../models/header_price_model.dart';

/// [HeaderPriceRepository]（domain層インターフェース）の実装クラス。
/// [HeaderPriceLocalDataSource]へ処理を委譲する。
class HeaderPriceRepositoryImpl implements HeaderPriceRepository {
  /// [HeaderPriceRepositoryImpl] を生成する。
  const HeaderPriceRepositoryImpl(this._dataSource);

  final HeaderPriceLocalDataSource _dataSource;

  @override
  Future<void> insert(final HeaderPrice headerPrice) async {
    final HeaderPriceModel model = HeaderPriceModel(
      priceId: headerPrice.priceId,
      columnId: headerPrice.columnId,
      price: headerPrice.price,
      effectiveFrom: headerPrice.effectiveFrom,
      effectiveTo: headerPrice.effectiveTo,
      createdAt: headerPrice.createdAt,
      updatedAt: headerPrice.updatedAt,
    );
    await _dataSource.insert(model);
  }

  @override
  Future<HeaderPrice> findCurrentPrice(
    final String columnId,
    final DateTime targetDate,
  ) async {
    final HeaderPrice result = await _dataSource.findCurrentPrice(
      columnId,
      targetDate,
    );
    return result;
  }

  @override
  Future<void> closeCurrentPrice(
    final String priceId,
    final DateTime effectiveTo,
  ) async {
    await _dataSource.closeCurrentPrice(priceId, effectiveTo);
  }
}
