import '../../domain/entities/sheet_instance.dart';
import '../../domain/repositories/sheet_instance_repository.dart';
import '../datasources/sheet_instance_local_datasource.dart';
import '../models/sheet_instance_model.dart';

/// [SheetInstanceRepository]（domain層インターフェース）の実装クラス。
/// [SheetInstanceLocalDataSource]へ処理を委譲する。
class SheetInstanceRepositoryImpl implements SheetInstanceRepository {
  /// [SheetInstanceRepositoryImpl] を生成する。
  const SheetInstanceRepositoryImpl(this._dataSource);

  final SheetInstanceLocalDataSource _dataSource;

  @override
  Future<void> insert(final SheetInstance instance) async {
    final SheetInstanceModel model = SheetInstanceModel(
      sheetInstanceId: instance.sheetInstanceId,
      sheetTemplateId: instance.sheetTemplateId,
      businessDate: instance.businessDate,
      status: instance.status,
      createdAt: instance.createdAt,
      updatedAt: instance.updatedAt,
    );
    await _dataSource.insert(model);
  }

  @override
  Future<SheetInstance> findById(final String sheetInstanceId) async {
    final SheetInstance result = await _dataSource.findById(sheetInstanceId);
    return result;
  }

  @override
  Future<SheetInstance?> findByTemplateAndDate(
    final String sheetTemplateId,
    final DateTime businessDate,
  ) async {
    final SheetInstance? result = await _dataSource.findByTemplateAndDate(
      sheetTemplateId,
      businessDate,
    );
    return result;
  }

  @override
  Future<List<SheetInstance>> findByTemplateIdAndDateRange(
    final String sheetTemplateId,
    final DateTime from,
    final DateTime to,
  ) async {
    final List<SheetInstance> result =
        await _dataSource.findByTemplateIdAndDateRange(
      sheetTemplateId,
      from,
      to,
    );
    return result;
  }
}
