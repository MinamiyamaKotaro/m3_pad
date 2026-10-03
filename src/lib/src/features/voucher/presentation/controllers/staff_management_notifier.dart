import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/staff.dart';
import 'staff_management_state.dart';
import 'voucher_providers.dart';

/// スタッフ管理画面（`MMM_004_VOUCHER`）の状態（[StaffManagementState]）を
/// 管理するRiverpod Notifier。
///
/// スタッフ一覧の読込・追加・氏名更新・論理削除（FR-7）を担う。
class StaffManagementNotifier extends Notifier<StaffManagementState> {
  @override
  StaffManagementState build() => const StaffManagementState();

  /// 画面生成時に呼び出され、有効なスタッフ一覧を読み込む。
  Future<void> load() async {
    state = state.copyWith(status: StaffManagementStatus.loading);
    try {
      final List<Staff> staffRoster =
          await ref.read(staffRepositoryProvider).findAllActive();
      state = state.copyWith(
        status: StaffManagementStatus.success,
        staffRoster: staffRoster,
      );
    } on Exception catch (error) {
      state = state.copyWith(
        status: StaffManagementStatus.error,
        errorMessage: error.toString(),
      );
    }
  }

  /// スタッフを1件追加する。成功時は`null`、失敗時はエラーメッセージを
  /// 返す。
  Future<String?> addStaff(final String name) =>
      _runAndReload(() => ref.read(addStaffUsecaseProvider).call(name: name));

  /// スタッフの氏名を更新する。成功時は`null`、失敗時はエラーメッセージを
  /// 返す。
  Future<String?> updateStaff(final String staffId, final String name) =>
      _runAndReload(
        () => ref
            .read(updateStaffUsecaseProvider)
            .call(staffId: staffId, name: name),
      );

  /// スタッフを論理削除する。成功時は`null`、失敗時はエラーメッセージを
  /// 返す。
  Future<String?> removeStaff(final String staffId) => _runAndReload(
        () => ref.read(removeStaffUsecaseProvider).call(staffId),
      );

  Future<String?> _runAndReload(final Future<void> Function() action) async {
    try {
      await action();
      await load();
      return null;
    } on Exception catch (error) {
      return error.toString();
    }
  }
}

/// [StaffManagementNotifier] を提供するプロバイダ。
final NotifierProvider<StaffManagementNotifier, StaffManagementState>
    staffManagementNotifierProvider =
    NotifierProvider<StaffManagementNotifier, StaffManagementState>(
  StaffManagementNotifier.new,
);
