import '../../domain/entities/header_type.dart';
import '../../domain/repositories/header_type_repository.dart';
import '../datasources/header_type_local_datasource.dart';

/// [HeaderTypeRepository]（domain層インターフェース）の実装クラス。
/// [HeaderTypeLocalDataSource]へ処理を委譲する。
class HeaderTypeRepositoryImpl implements HeaderTypeRepository {
  /// [HeaderTypeRepositoryImpl] を生成する。
  const HeaderTypeRepositoryImpl(this._dataSource);

  final HeaderTypeLocalDataSource _dataSource;

  @override
  Future<List<HeaderType>> findAll() async {
    final List<HeaderType> result = await _dataSource.findAll();
    return result;
  }

  @override
  Future<HeaderType> findById(final int typeId) async {
    final HeaderType result = await _dataSource.findById(typeId);
    return result;
  }
}
