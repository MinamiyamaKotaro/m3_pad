import '../../domain/entities/staff.dart';

/// スタッフ管理画面（`MMM_004_VOUCHER`）のライフサイクル状態。
enum StaffManagementStatus {
  /// 画面生成直後、まだ読み込みを開始していない状態。
  initial,

  /// データ取得中（インジケータ表示用）。
  loading,

  /// データが正常に取得でき、画面描画が可能な状態。
  success,

  /// 取得に失敗した異常系（エラーメッセージ・再試行ボタン表示用）。
  error,
}

/// スタッフ管理画面（`MMM_004_VOUCHER`）のUI状態（UiState）を表すクラス。
///
/// StaffManagementNotifierが保持・更新し、StaffManagementPageが監視する。
class StaffManagementState {
  /// [StaffManagementState] を生成する。
  const StaffManagementState({
    this.status = StaffManagementStatus.initial,
    this.staffRoster = const <Staff>[],
    this.errorMessage,
  });

  /// 画面状態。
  final StaffManagementStatus status;

  /// 有効なスタッフ一覧。
  final List<Staff> staffRoster;

  /// エラーメッセージ。`status`が`error`の場合のみ非`null`。
  final String? errorMessage;

  /// 一部のプロパティのみを変更した新しい [StaffManagementState] を生成する。
  StaffManagementState copyWith({
    final StaffManagementStatus? status,
    final List<Staff>? staffRoster,
    final String? errorMessage,
  }) =>
      StaffManagementState(
        status: status ?? this.status,
        staffRoster: staffRoster ?? this.staffRoster,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}
