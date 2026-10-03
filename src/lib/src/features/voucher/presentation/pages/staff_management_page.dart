import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/loading_indicator.dart';
import '../../domain/entities/staff.dart';
import '../controllers/staff_management_notifier.dart';
import '../controllers/staff_management_state.dart';

/// スタッフ管理画面（画面ID: `MMM_004_VOUCHER`）。
///
/// スタッフの氏名を追加・編集・削除（論理削除）する（FR-7）。
class StaffManagementPage extends ConsumerStatefulWidget {
  /// [StaffManagementPage] を生成する。
  const StaffManagementPage({super.key});

  @override
  ConsumerState<StaffManagementPage> createState() =>
      _StaffManagementPageState();
}

class _StaffManagementPageState extends ConsumerState<StaffManagementPage> {
  @override
  void initState() {
    super.initState();
    unawaited(
      Future<void>.microtask(
        () => ref.read(staffManagementNotifierProvider.notifier).load(),
      ),
    );
  }

  Future<void> _showErrorIfAny(final String? errorMessage) async {
    if (errorMessage == null || !mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
  }

  Future<void> _showStaffForm({final Staff? staff}) async {
    final String? name = await showDialog<String>(
      context: context,
      builder: (final BuildContext context) => _StaffFormDialog(staff: staff),
    );
    if (name == null || !mounted) {
      return;
    }

    final StaffManagementNotifier notifier = ref.read(
      staffManagementNotifierProvider.notifier,
    );
    final String? errorMessage = staff == null
        ? await notifier.addStaff(name)
        : await notifier.updateStaff(staff.staffId, name);
    await _showErrorIfAny(errorMessage);
  }

  Future<void> _confirmRemove(final Staff staff) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (final BuildContext context) => AlertDialog(
        title: const Text('スタッフを削除'),
        content: Text('「${staff.name}」を削除します。よろしいですか？'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('削除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }
    final String? errorMessage = await ref
        .read(staffManagementNotifierProvider.notifier)
        .removeStaff(staff.staffId);
    await _showErrorIfAny(errorMessage);
  }

  @override
  Widget build(final BuildContext context) {
    final StaffManagementState state = ref.watch(
      staffManagementNotifierProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('スタッフ管理'),
            Text('MMM_004_VOUCHER', style: TextStyle(fontSize: 11)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showStaffForm,
        child: const Icon(Icons.add),
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(final StaffManagementState state) {
    switch (state.status) {
      case StaffManagementStatus.initial:
      case StaffManagementStatus.loading:
        return const LoadingIndicator();
      case StaffManagementStatus.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(state.errorMessage ?? ''),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    ref.read(staffManagementNotifierProvider.notifier).load(),
                child: const Text('再試行'),
              ),
            ],
          ),
        );
      case StaffManagementStatus.success:
        if (state.staffRoster.isEmpty) {
          return const Center(child: Text('スタッフが登録されていません'));
        }
        return ListView.builder(
          itemCount: state.staffRoster.length,
          itemBuilder: (final BuildContext context, final int index) {
            final Staff staff = state.staffRoster[index];
            return ListTile(
              title: Text(staff.name),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showStaffForm(staff: staff),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _confirmRemove(staff),
                  ),
                ],
              ),
            );
          },
        );
    }
  }
}

/// スタッフの追加・編集フォームダイアログ。
///
/// 氏名入力欄の[TextEditingController]は、ダイアログが閉じるアニメーションの
/// 完了後（Stateの`dispose`時）に破棄する。`showDialog`の戻り直後に破棄すると、
/// 閉じるアニメーション中の再描画で破棄済みのコントローラーが参照され例外となる
/// ため、State側で所有する。
class _StaffFormDialog extends StatefulWidget {
  const _StaffFormDialog({this.staff});

  /// 編集対象のスタッフ。追加の場合は`null`。
  final Staff? staff;

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Staff?>('staff', staff));
  }

  @override
  State<_StaffFormDialog> createState() => _StaffFormDialogState();
}

class _StaffFormDialogState extends State<_StaffFormDialog> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.staff?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => AlertDialog(
        title: Text(widget.staff == null ? 'スタッフを追加' : 'スタッフを編集'),
        content: TextField(
          controller: _nameController,
          autofocus: true,
          decoration: const InputDecoration(labelText: '氏名'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(_nameController.text),
            child: const Text('保存'),
          ),
        ],
      );
}
