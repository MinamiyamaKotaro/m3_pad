import 'enums/enums.dart';

/// 伝票右上の「スタッフ」欄（氏名・就業時刻・ドリンクバック）を表す
/// ドメインエンティティ。`SheetRow`の担当スタッフ（会計を行った人）とは
/// 別概念で、営業日単位でのスタッフの勤務記録を表す。
class StaffShift {
  /// [StaffShift] を生成する。
  const StaffShift({
    required this.shiftId,
    required this.sheetInstanceId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.staffId,
    this.startTime,
    this.endTime,
    this.drinkBack,
  });

  /// シフトID。
  final String shiftId;

  /// どの日のシフトか。
  final String sheetInstanceId;

  /// 対象スタッフ。未選択（「未定」）の場合は`null`。
  final String? staffId;

  /// 就業開始時刻（`HH:mm`形式）。未入力の場合は`null`。
  final String? startTime;

  /// 就業終了時刻（`HH:mm`形式）。未入力の場合は`null`。
  final String? endTime;

  /// 「D」欄（ドリンクバック）の自由記述。
  final String? drinkBack;

  /// 論理削除状態。
  final RecordStatus status;

  /// 作成日時。
  final DateTime createdAt;

  /// 更新日時。
  final DateTime updatedAt;
}
