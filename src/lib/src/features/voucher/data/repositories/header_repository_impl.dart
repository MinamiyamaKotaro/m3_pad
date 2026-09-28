import '../../domain/entities/enums/enums.dart';
import '../../domain/entities/header.dart';
import '../../domain/repositories/header_repository.dart';
import '../datasources/header_local_datasource.dart';
import '../models/header_model.dart';

/// [HeaderRepository]（domain層インターフェース）の実装クラス。
/// [HeaderLocalDataSource]へ処理を委譲する。
class HeaderRepositoryImpl implements HeaderRepository {
  /// [HeaderRepositoryImpl] を生成する。
  const HeaderRepositoryImpl(this._dataSource);

  final HeaderLocalDataSource _dataSource;

  @override
  Future<void> insert(final Header header) async {
    final HeaderModel model = HeaderModel(
      columnId: header.columnId,
      sheetTemplateId: header.sheetTemplateId,
      typeId: header.typeId,
      name: header.name,
      displayOrder: header.displayOrder,
      isPriced: header.isPriced,
      status: header.status,
      createdAt: header.createdAt,
      updatedAt: header.updatedAt,
    );
    await _dataSource.insert(model);
  }

  @override
  Future<Header> findById(final String columnId) async {
    final Header result = await _dataSource.findById(columnId);
    return result;
  }

  @override
  Future<List<Header>> findByTemplateId(final String sheetTemplateId) async {
    final List<Header> result = await _dataSource.findByTemplateId(
      sheetTemplateId,
    );
    return result;
  }

  @override
  Future<void> updateDisplayOrders(
    final Map<String, int> displayOrderByColumnId,
  ) async {
    await _dataSource.updateDisplayOrders(displayOrderByColumnId);
  }

  @override
  Future<void> updateStatus(
    final String columnId,
    final RecordStatus status,
  ) async {
    await _dataSource.updateStatus(columnId, status);
  }
}
