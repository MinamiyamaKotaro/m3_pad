import '../entities/enums/enums.dart';
import '../repositories/staff_repository.dart';

/// スタッフを論理削除するユースケース（FR-7）。
///
/// 物理削除は行わず`status=deleted`への更新のみを行うため、過去の伝票データ
/// （`t_row.staff_id`・`t_staff_shift.staff_id`）は削除後も保持される。
class RemoveStaffUsecase {
  /// [RemoveStaffUsecase] を生成する。
  const RemoveStaffUsecase({
    required final StaffRepository staffRepository,
  }) : _staffRepository = staffRepository;

  final StaffRepository _staffRepository;

  /// [staffId] のスタッフを論理削除する。
  Future<void> call(final String staffId) async {
    await _staffRepository.findById(staffId);
    await _staffRepository.updateStatus(staffId, RecordStatus.deleted);
  }
}
