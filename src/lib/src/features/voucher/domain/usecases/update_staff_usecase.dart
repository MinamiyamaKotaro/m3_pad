import '../../../../core/errors/validation_exception.dart';
import '../repositories/staff_repository.dart';

/// スタッフの氏名を更新するユースケース（FR-7）。
class UpdateStaffUsecase {
  /// [UpdateStaffUsecase] を生成する。
  const UpdateStaffUsecase({
    required final StaffRepository staffRepository,
  }) : _staffRepository = staffRepository;

  final StaffRepository _staffRepository;

  /// [staffId] のスタッフの氏名を[name]に更新する。
  Future<void> call({
    required final String staffId,
    required final String name,
  }) async {
    await _staffRepository.findById(staffId);
    if (name.trim().isEmpty) {
      throw const ValidationException(reason: '氏名は必須です');
    }
    await _staffRepository.updateName(staffId, name);
  }
}
