import '../../domain/entities/enums/enums.dart';
import '../../domain/entities/staff.dart';
import '../../domain/repositories/staff_repository.dart';
import '../datasources/staff_local_datasource.dart';
import '../models/staff_model.dart';

/// [StaffRepository]（domain層インターフェース）の実装クラス。
/// [StaffLocalDataSource]へ処理を委譲する。
class StaffRepositoryImpl implements StaffRepository {
  /// [StaffRepositoryImpl] を生成する。
  const StaffRepositoryImpl(this._dataSource);

  final StaffLocalDataSource _dataSource;

  @override
  Future<void> insert(final Staff staff) async {
    final StaffModel model = StaffModel(
      staffId: staff.staffId,
      name: staff.name,
      staffCode: staff.staffCode,
      status: staff.status,
      createdAt: staff.createdAt,
      updatedAt: staff.updatedAt,
    );
    await _dataSource.insert(model);
  }

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

  @override
  Future<void> updateName(final String staffId, final String name) async {
    await _dataSource.updateName(staffId, name);
  }

  @override
  Future<void> updateStatus(
    final String staffId,
    final RecordStatus status,
  ) async {
    await _dataSource.updateStatus(staffId, status);
  }
}
