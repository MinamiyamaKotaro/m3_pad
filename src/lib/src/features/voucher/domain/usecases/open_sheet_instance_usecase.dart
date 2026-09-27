import '../../../../core/utils/id_generator.dart';
import '../entities/enums/enums.dart';
import '../entities/sheet_instance.dart';
import '../entities/staff_shift.dart';
import '../repositories/sheet_instance_repository.dart';
import '../repositories/sheet_template_repository.dart';
import '../repositories/staff_shift_repository.dart';

/// 指定した伝票フォーマット・営業日の伝票インスタンス（[SheetInstance]）を
/// 取得する。存在しない場合は新規作成し、あわせて紙伝票の
/// 「(氏名) ~ D」形式の行が3行であることに合わせて、空の[StaffShift]を
/// 3件作成する（FR-1、FR-2）。
class OpenSheetInstanceUsecase {
  /// [OpenSheetInstanceUsecase] を生成する。
  const OpenSheetInstanceUsecase({
    required final SheetTemplateRepository templateRepository,
    required final SheetInstanceRepository instanceRepository,
    required final StaffShiftRepository staffShiftRepository,
    required final IdGenerator idGenerator,
  })  : _templateRepository = templateRepository,
        _instanceRepository = instanceRepository,
        _staffShiftRepository = staffShiftRepository,
        _idGenerator = idGenerator;

  /// 紙伝票右上の「スタッフ」欄のシフト枠数。
  static const int _staffShiftCount = 3;

  final SheetTemplateRepository _templateRepository;
  final SheetInstanceRepository _instanceRepository;
  final StaffShiftRepository _staffShiftRepository;
  final IdGenerator _idGenerator;

  /// 指定した [sheetTemplateId]・[businessDate] の伝票インスタンスを取得する。
  /// 存在しない場合は新規作成する。
  Future<SheetInstance> call(
    final String sheetTemplateId,
    final DateTime businessDate,
  ) async {
    await _templateRepository.findById(sheetTemplateId);

    final SheetInstance? existingInstance = await _instanceRepository
        .findByTemplateAndDate(sheetTemplateId, businessDate);
    if (existingInstance != null) {
      return existingInstance;
    }

    final String sheetInstanceId = _idGenerator.generate();
    final DateTime now = DateTime.now();
    final SheetInstance newInstance = SheetInstance(
      sheetInstanceId: sheetInstanceId,
      sheetTemplateId: sheetTemplateId,
      businessDate: businessDate,
      status: RecordStatus.active,
      createdAt: now,
      updatedAt: now,
    );
    await _instanceRepository.insert(newInstance);

    for (int i = 0; i < _staffShiftCount; i++) {
      final String shiftId = _idGenerator.generate();
      final StaffShift shift = StaffShift(
        shiftId: shiftId,
        sheetInstanceId: sheetInstanceId,
        status: RecordStatus.active,
        createdAt: now,
        updatedAt: now,
      );
      await _staffShiftRepository.insert(shift);
    }

    return newInstance;
  }
}
