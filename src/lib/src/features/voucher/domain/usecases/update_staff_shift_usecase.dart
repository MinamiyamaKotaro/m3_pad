import '../entities/staff_shift.dart';
import '../repositories/staff_shift_repository.dart';

/// 右上「スタッフ」欄の氏名プルダウン・就業時刻ボタン・ドリンクバック入力の
/// 確定時に呼び出され、[StaffShift]を部分更新するユースケース。
///
/// 項目ごとに呼び出されるため、更新対象以外は現在値を維持する。
class UpdateStaffShiftUsecase {
  /// [UpdateStaffShiftUsecase] を生成する。
  const UpdateStaffShiftUsecase({
    required final StaffShiftRepository staffShiftRepository,
  }) : _staffShiftRepository = staffShiftRepository;

  final StaffShiftRepository _staffShiftRepository;

  /// [current] のうち、指定された項目のみを更新する。
  ///
  /// `staffId`を更新する場合は[hasStaffId]を`true`にする（「未定」選択時は
  /// `staffId=null`のまま[hasStaffId]のみ`true`にする）。
  Future<StaffShift> call({
    required final StaffShift current,
    final String? staffId,
    final bool hasStaffId = false,
    final String? startTime,
    final String? endTime,
    final String? drinkBack,
  }) async {
    final StaffShift updated = StaffShift(
      shiftId: current.shiftId,
      sheetInstanceId: current.sheetInstanceId,
      staffId: hasStaffId ? staffId : current.staffId,
      startTime: startTime ?? current.startTime,
      endTime: endTime ?? current.endTime,
      drinkBack: drinkBack ?? current.drinkBack,
      status: current.status,
      createdAt: current.createdAt,
      updatedAt: DateTime.now(),
    );
    await _staffShiftRepository.update(updated);
    return updated;
  }
}
