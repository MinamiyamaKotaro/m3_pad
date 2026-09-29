import '../../../../core/errors/validation_exception.dart';
import '../../../../core/utils/id_generator.dart';
import '../entities/enums/enums.dart';
import '../entities/staff.dart';
import '../repositories/staff_repository.dart';

/// スタッフを1件追加するユースケース（FR-7）。
///
/// 過去に論理削除した同名のスタッフが存在する場合は、重複して新規作成せず
/// 論理削除を取り消す（復元する）。
class AddStaffUsecase {
  /// [AddStaffUsecase] を生成する。
  const AddStaffUsecase({
    required final StaffRepository staffRepository,
    required final IdGenerator idGenerator,
  })  : _staffRepository = staffRepository,
        _idGenerator = idGenerator;

  final StaffRepository _staffRepository;
  final IdGenerator _idGenerator;

  /// 指定した [name] のスタッフを追加する。
  Future<Staff> call({required final String name}) async {
    if (name.trim().isEmpty) {
      throw const ValidationException(reason: '氏名は必須です');
    }

    final Staff? existing = await _staffRepository.findByName(name);
    if (existing != null && existing.status == RecordStatus.deleted) {
      final DateTime now = DateTime.now();
      await _staffRepository.updateStatus(
        existing.staffId,
        RecordStatus.active,
      );
      return Staff(
        staffId: existing.staffId,
        name: existing.name,
        staffCode: existing.staffCode,
        status: RecordStatus.active,
        createdAt: existing.createdAt,
        updatedAt: now,
      );
    }

    final String staffId = _idGenerator.generate();
    final DateTime now = DateTime.now();
    final Staff staff = Staff(
      staffId: staffId,
      name: name,
      status: RecordStatus.active,
      createdAt: now,
      updatedAt: now,
    );
    await _staffRepository.insert(staff);
    return staff;
  }
}
