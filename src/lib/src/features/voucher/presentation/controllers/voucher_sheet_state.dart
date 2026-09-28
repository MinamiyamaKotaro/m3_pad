import '../../domain/entities/sheet_detail.dart';

/// 伝票入力画面（`MMM_001_VOUCHER`）のライフサイクル状態。
enum VoucherSheetStatus {
  /// 画面生成直後、まだ読み込みを開始していない状態。
  initial,

  /// データ取得中（インジケータ表示用）。
  loading,

  /// データが正常に取得でき、画面描画が可能な状態。
  success,

  /// 取得できたが行が0件の状態（空状態専用UI表示用）。
  empty,

  /// 取得・更新に失敗した異常系（エラーメッセージ・再試行ボタン表示用）。
  error,
}

/// 伝票入力画面（`MMM_001_VOUCHER`）のUI状態（UiState）を表すクラス。
///
/// VoucherSheetNotifierが保持・更新し、VoucherSheetPageが監視する。
class VoucherSheetState {
  /// [VoucherSheetState] を生成する。
  const VoucherSheetState({
    this.status = VoucherSheetStatus.initial,
    this.sheetDetail,
    this.errorMessage,
    this.editingRowId,
    this.editingColumnId,
    this.editingText,
    this.editingStaffShiftId,
    this.editingStaffShiftField,
    this.isExporting = false,
  });

  /// 画面状態。
  final VoucherSheetStatus status;

  /// 伝票詳細。`status`が`success`/`empty`の場合のみ非`null`。
  final SheetDetail? sheetDetail;

  /// エラーメッセージ。`status`が`error`の場合のみ非`null`。
  final String? errorMessage;

  /// 編集中の行ID。セル編集中のみ非`null`。
  final String? editingRowId;

  /// 編集中の列ID。「お名前」列編集中の場合は特別な値`'customerName'`。
  final String? editingColumnId;

  /// 編集中の入力テキスト。
  final String? editingText;

  /// 編集中のシフトID。就業時刻ボタンをタップして編集中の場合のみ非`null`。
  final String? editingStaffShiftId;

  /// 編集中のシフト項目。`'start'`または`'end'`。
  final String? editingStaffShiftField;

  /// CSV出力中フラグ。
  final bool isExporting;

  /// 一部のプロパティのみを変更した新しい [VoucherSheetState] を生成する。
  VoucherSheetState copyWith({
    final VoucherSheetStatus? status,
    final SheetDetail? sheetDetail,
    final String? errorMessage,
    final bool clearEditing = false,
    final String? editingRowId,
    final String? editingColumnId,
    final String? editingText,
    final bool clearEditingStaffShift = false,
    final String? editingStaffShiftId,
    final String? editingStaffShiftField,
    final bool? isExporting,
  }) =>
      VoucherSheetState(
        status: status ?? this.status,
        sheetDetail: sheetDetail ?? this.sheetDetail,
        errorMessage: errorMessage ?? this.errorMessage,
        editingRowId: clearEditing ? null : (editingRowId ?? this.editingRowId),
        editingColumnId:
            clearEditing ? null : (editingColumnId ?? this.editingColumnId),
        editingText: clearEditing ? null : (editingText ?? this.editingText),
        editingStaffShiftId: clearEditingStaffShift
            ? null
            : (editingStaffShiftId ?? this.editingStaffShiftId),
        editingStaffShiftField: clearEditingStaffShift
            ? null
            : (editingStaffShiftField ?? this.editingStaffShiftField),
        isExporting: isExporting ?? this.isExporting,
      );
}
