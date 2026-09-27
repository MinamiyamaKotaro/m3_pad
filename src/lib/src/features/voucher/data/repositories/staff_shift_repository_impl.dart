import '../../domain/entities/staff_shift.dart';
import '../../domain/repositories/staff_shift_repository.dart';
import '../datasources/staff_shift_local_datasource.dart';
import '../models/staff_shift_model.dart';

/// [StaffShiftRepository]（domain層インターフェース）の実装クラス。
/// [StaffShiftLocalDataSource]へ処理を委譲する。
class StaffShiftRepositoryImpl implements StaffShiftRepository {
  /// [StaffShiftRepositoryImpl] を生成する。
  const StaffShiftRepositoryImpl(this._dataSource);

  final StaffShiftLocalDataSource _dataSource;

  @override
  Future<void> insert(final StaffShift shift) async {
    final StaffShiftModel model = StaffShiftModel(
      shiftId: shift.shiftId,
      sheetInstanceId: shift.sheetInstanceId,
      staffId: shift.staffId,
      startTime: shift.startTime,
      endTime: shift.endTime,
      drinkBack: shift.drinkBack,
      status: shift.status,
      createdAt: shift.createdAt,
      updatedAt: shift.updatedAt,
    );
    await _dataSource.insert(model);
  }

  @override
  Future<void> update(final StaffShift shift) async {
    final StaffShiftModel model = StaffShiftModel(
      shiftId: shift.shiftId,
      sheetInstanceId: shift.sheetInstanceId,
      staffId: shift.staffId,
      startTime: shift.startTime,
      endTime: shift.endTime,
      drinkBack: shift.drinkBack,
      status: shift.status,
      createdAt: shift.createdAt,
      updatedAt: shift.updatedAt,
    );
    await _dataSource.update(model);
  }

  @override
  Future<List<StaffShift>> findByInstanceId(
    final String sheetInstanceId,
  ) async {
    final List<StaffShift> result = await _dataSource.findByInstanceId(
      sheetInstanceId,
    );
    return result;
  }
}
