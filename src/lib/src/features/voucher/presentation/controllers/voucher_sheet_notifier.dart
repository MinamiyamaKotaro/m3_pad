import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/time_format.dart';
import '../../domain/entities/enums/enums.dart';
import '../../domain/entities/header.dart';
import '../../domain/entities/sheet_detail.dart';
import '../../domain/entities/sheet_instance.dart';
import '../../domain/entities/sheet_row.dart';
import '../../domain/entities/staff_shift.dart';
import 'voucher_providers.dart';
import 'voucher_sheet_effect.dart';
import 'voucher_sheet_effect_provider.dart';
import 'voucher_sheet_state.dart';

/// 伝票入力画面（`MMM_001_VOUCHER`）の状態（[VoucherSheetState]）を管理する
/// Riverpod Notifier。
///
/// 伝票インスタンスの読込・行追加・セル入力・行の付帯情報（お名前・担当・
/// 決済方法）更新・スタッフ欄更新・CSV出力（FR-1〜FR-3）を担う。
class VoucherSheetNotifier extends Notifier<VoucherSheetState> {
  String? _sheetInstanceId;

  @override
  VoucherSheetState build() => const VoucherSheetState();

  /// 画面生成時に呼び出され、伝票インスタンスを取得（なければ新規作成）し、
  /// 表示用の[SheetDetail]を読み込む。
  Future<void> load({
    required final String sheetTemplateId,
    required final DateTime businessDate,
  }) async {
    state = state.copyWith(status: VoucherSheetStatus.loading);
    try {
      final SheetInstance instance = await ref
          .read(openSheetInstanceUsecaseProvider)
          .call(sheetTemplateId, businessDate);
      _sheetInstanceId = instance.sheetInstanceId;
      await _reload();
    } on Exception catch (error) {
      state = state.copyWith(
        status: VoucherSheetStatus.error,
        errorMessage: error.toString(),
      );
    }
  }

  /// Error状態からの再試行。[load]と同じ引数で再実行する。
  Future<void> retry({
    required final String sheetTemplateId,
    required final DateTime businessDate,
  }) =>
      load(sheetTemplateId: sheetTemplateId, businessDate: businessDate);

  /// 設定画面（ヘッダー・スタッフの追加・更新・削除）から戻った際に
  /// 呼び出され、表示中の伝票インスタンスを読込中表示を挟まずに再読込する。
  /// 未読込（[load]前）の場合は何もしない。
  Future<void> refresh() async {
    if (_sheetInstanceId == null) {
      return;
    }
    try {
      await _reload();
    } on Exception catch (error) {
      state = state.copyWith(
        status: VoucherSheetStatus.error,
        errorMessage: error.toString(),
      );
    }
  }

  /// 現在の伝票インスタンスに1組の来店・卓を追加し、表示を更新する。
  Future<void> addRow({final String? customerId, final String? staffId}) =>
      _runOrNotifyFailure(
        () => ref.read(addRowUsecaseProvider).call(
              _requireInstanceId(),
              customerId: customerId,
              staffId: staffId,
            ),
      );

  /// セルタップ時に呼び出され、編集中セルの位置と初期テキストを状態に反映
  /// する（DB・usecase呼び出しなし）。
  void startEditingCell(
    final String rowId,
    final String columnId,
    final String initialText,
  ) {
    state = state.copyWith(
      editingRowId: rowId,
      editingColumnId: columnId,
      editingText: initialText,
    );
  }

  /// 編集中セルのテキストフィールド入力値の変化を状態に反映する。
  void updateEditingText(final String text) {
    state = state.copyWith(editingText: text);
  }

  /// 編集中セルの入力を確定し保存する。
  ///
  /// `editingColumnId`が`'customerName'`の場合はUpdateRowUsecaseへ、
  /// それ以外は実在の列IDとみなしInputCellUsecaseへ保存する。
  Future<void> commitCell() async {
    final String? rowId = state.editingRowId;
    final String? columnId = state.editingColumnId;
    final String? text = state.editingText;
    if (rowId == null || columnId == null || text == null) {
      return;
    }

    if (columnId == 'customerName') {
      final SheetRow current = _findRow(rowId);
      await _runOrNotifyFailure(() async {
        await ref
            .read(updateRowUsecaseProvider)
            .call(current, customerName: text);
        state = state.copyWith(clearEditing: true);
      });
      return;
    }

    final SheetDetail detail = _requireDetail();
    final Header header = detail.headers.firstWhere(
      (final Header h) => h.columnId == columnId,
    );
    await _runOrNotifyFailure(() async {
      if (header.isPriced) {
        await ref
            .read(inputCellUsecaseProvider)
            .call(rowId: rowId, columnId: columnId, quantity: int.parse(text));
      } else {
        await ref
            .read(inputCellUsecaseProvider)
            .call(rowId: rowId, columnId: columnId, content: text);
      }
      state = state.copyWith(clearEditing: true);
    });
  }

  /// 「担当」列プルダウンでの選択確定時に呼び出す。
  Future<void> setRowStaff(final String rowId, final String? staffId) async {
    final SheetRow current = _findRow(rowId);
    await _runOrNotifyFailure(
      () => ref
          .read(updateRowUsecaseProvider)
          .call(current, staffId: staffId, hasStaffId: true),
    );
  }

  /// 「合計金額」列に隣接する「P」「カ」トグルのタップ時に呼び出す。
  Future<void> setRowPaymentMethod(
    final String rowId,
    final PaymentMethod? paymentMethod,
  ) async {
    final SheetRow current = _findRow(rowId);
    await _runOrNotifyFailure(
      () => ref.read(updateRowUsecaseProvider).call(
            current,
            paymentMethod: paymentMethod,
            hasPaymentMethod: true,
          ),
    );
  }

  /// スタッフ欄の氏名プルダウンでの選択確定時に呼び出す。
  Future<void> setStaffShiftName(
    final String shiftId,
    final String? staffId,
  ) async {
    final StaffShift current = _findShift(shiftId);
    await _runOrNotifyFailure(
      () => ref
          .read(updateStaffShiftUsecaseProvider)
          .call(current: current, staffId: staffId, hasStaffId: true),
    );
  }

  /// スタッフ欄のドリンクバック入力欄のフォーカスアウト時に呼び出す。
  Future<void> setStaffShiftDrinkBack(
    final String shiftId,
    final String drinkBack,
  ) async {
    final StaffShift current = _findShift(shiftId);
    await _runOrNotifyFailure(
      () => ref
          .read(updateStaffShiftUsecaseProvider)
          .call(current: current, drinkBack: drinkBack),
    );
  }

  /// 就業時刻ボタンのタップ時に呼び出し、編集中シフトの位置を状態に反映
  /// する。
  void startEditingStaffShiftTime(final String shiftId, final String field) {
    state = state.copyWith(
      editingStaffShiftId: shiftId,
      editingStaffShiftField: field,
    );
  }

  /// 就業時刻編集の確定時に呼び出す。
  ///
  /// [value] を`HH:mm`形式に正規化して保存する。形式不正の場合は保存せず
  /// 編集を終了し、`cellInputFailed`を通知する。
  Future<void> commitStaffShiftTime(final String value) async {
    final String? shiftId = state.editingStaffShiftId;
    final String? field = state.editingStaffShiftField;
    if (shiftId == null || field == null) {
      return;
    }
    final String? time = normalizeHHmm(value);
    if (time == null) {
      _clearEditingStaffShiftIfStill(shiftId, field);
      ref.read(voucherSheetEffectProvider.notifier).emit(
            const VoucherSheetEffect(
              kind: VoucherSheetEffectKind.cellInputFailed,
              message: '時刻はHH:mm形式（例: 18:30）で入力してください',
            ),
          );
      return;
    }
    final StaffShift current = _findShift(shiftId);
    await _runOrNotifyFailure(() async {
      await ref.read(updateStaffShiftUsecaseProvider).call(
            current: current,
            startTime: field == 'start' ? time : null,
            endTime: field == 'end' ? time : null,
          );
      _clearEditingStaffShiftIfStill(shiftId, field);
    });
  }

  /// 編集中のシフト時刻が[shiftId]・[field]のままの場合のみ編集状態を解除
  /// する（保存待ちの間に別の時刻ボタンがタップされた場合、その編集状態を
  /// 消さないため）。
  void _clearEditingStaffShiftIfStill(
    final String shiftId,
    final String field,
  ) {
    if (state.editingStaffShiftId == shiftId &&
        state.editingStaffShiftField == field) {
      state = state.copyWith(clearEditingStaffShift: true);
    }
  }

  /// 現在の伝票インスタンスをCSVとして出力する。
  Future<void> exportCsv() async {
    state = state.copyWith(isExporting: true);
    try {
      final String csvContent = await ref
          .read(exportDailySheetToCsvUsecaseProvider)
          .call(_requireInstanceId());
      ref.read(voucherSheetEffectProvider.notifier).emit(
            VoucherSheetEffect(
              kind: VoucherSheetEffectKind.exportSucceeded,
              message: 'CSV出力が完了しました',
              csvContent: csvContent,
            ),
          );
    } on Exception catch (error) {
      ref.read(voucherSheetEffectProvider.notifier).emit(
            VoucherSheetEffect(
              kind: VoucherSheetEffectKind.exportFailed,
              message: error.toString(),
            ),
          );
    } finally {
      state = state.copyWith(isExporting: false);
    }
  }

  Future<void> _reload() async {
    final SheetDetail detail = await ref
        .read(getSheetDetailUsecaseProvider)
        .call(_requireInstanceId());
    state = state.copyWith(
      status: detail.rows.isEmpty
          ? VoucherSheetStatus.empty
          : VoucherSheetStatus.success,
      sheetDetail: detail,
    );
  }

  Future<void> _runOrNotifyFailure(final Future<void> Function() action) async {
    try {
      await action();
      await _reload();
    } on Exception catch (error) {
      ref.read(voucherSheetEffectProvider.notifier).emit(
            VoucherSheetEffect(
              kind: VoucherSheetEffectKind.cellInputFailed,
              message: error.toString(),
            ),
          );
    }
  }

  String _requireInstanceId() {
    final String? id = _sheetInstanceId;
    if (id == null) {
      throw StateError('sheetInstanceId is not loaded yet');
    }
    return id;
  }

  SheetDetail _requireDetail() {
    final SheetDetail? detail = state.sheetDetail;
    if (detail == null) {
      throw StateError('sheetDetail is not loaded yet');
    }
    return detail;
  }

  SheetRow _findRow(final String rowId) => _requireDetail().rows.firstWhere(
        (final SheetRow row) => row.rowId == rowId,
      );

  StaffShift _findShift(final String shiftId) => _requireDetail()
      .staffShifts
      .firstWhere((final StaffShift shift) => shift.shiftId == shiftId);
}

/// [VoucherSheetNotifier] を提供するプロバイダ。
final NotifierProvider<VoucherSheetNotifier, VoucherSheetState>
    voucherSheetNotifierProvider =
    NotifierProvider<VoucherSheetNotifier, VoucherSheetState>(
  VoucherSheetNotifier.new,
);
