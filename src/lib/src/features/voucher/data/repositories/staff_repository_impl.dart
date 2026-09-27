import '../../domain/entities/staff.dart';
import '../../domain/repositories/staff_repository.dart';
import '../datasources/staff_local_datasource.dart';

/// [StaffRepository]（domain層インターフェース）の実装クラス。
/// [StaffLocalDataSource]へ処理を委譲する。
class StaffRepositoryImpl implements StaffRepository {
  /// [StaffRepositoryImpl] を生成する。
  const StaffRepositoryImpl(this._dataSource);

  final StaffLocalDataSource _dataSource;

  @override
  Future<Staff> findById(final String staffId) async {
    final Staff result = await _dataSource.findById(staffId);
    return result;
  }

  @override
  Future<List<Staff>> findAllActive() async {
    final List<Staff> result = await _dataSource.findAllActive();
    return result;
  }
}
