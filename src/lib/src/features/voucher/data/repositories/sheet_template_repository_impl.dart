import '../../domain/entities/sheet_template.dart';
import '../../domain/repositories/sheet_template_repository.dart';
import '../datasources/sheet_template_local_datasource.dart';
import '../models/sheet_template_model.dart';

/// [SheetTemplateRepository]（domain層インターフェース）の実装クラス。
/// [SheetTemplateLocalDataSource]へ処理を委譲する。
class SheetTemplateRepositoryImpl implements SheetTemplateRepository {
  /// [SheetTemplateRepositoryImpl] を生成する。
  const SheetTemplateRepositoryImpl(this._dataSource);

  final SheetTemplateLocalDataSource _dataSource;

  @override
  Future<void> insert(final SheetTemplate template) async {
    final SheetTemplateModel model = SheetTemplateModel(
      sheetTemplateId: template.sheetTemplateId,
      name: template.name,
      status: template.status,
      createdAt: template.createdAt,
      updatedAt: template.updatedAt,
    );
    await _dataSource.insert(model);
  }

  @override
  Future<SheetTemplate> findById(final String sheetTemplateId) async {
    final SheetTemplate result = await _dataSource.findById(sheetTemplateId);
    return result;
  }

  @override
  Future<List<SheetTemplate>> findAllActive() async {
    final List<SheetTemplate> result = await _dataSource.findAllActive();
    return result;
  }
}
