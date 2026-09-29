import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_format.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../domain/entities/enums/enums.dart';
import '../../domain/entities/header.dart';
import '../controllers/header_management_notifier.dart';
import '../controllers/header_management_state.dart';

/// カテゴリーの選択肢と表示ラベルの対応。
const Map<HeaderCategory, String> _categoryLabels = <HeaderCategory, String>{
  HeaderCategory.none: '未指定',
  HeaderCategory.drink: 'ドリンク',
  HeaderCategory.bottle: 'ボトル',
  HeaderCategory.food: 'フード',
};

/// ヘッダー管理画面（画面ID: `MMM_003_VOUCHER`）。
///
/// 「お名前」「MEMO」「合計金額」「担当」以外の価格対象の列（項目名・
/// カテゴリー・単価・表示/非表示）を追加・編集する（FR-6）。
class HeaderManagementPage extends ConsumerStatefulWidget {
  /// [HeaderManagementPage] を生成する。
  const HeaderManagementPage({required this.sheetTemplateId, super.key});

  /// 対象の伝票フォーマットID。
  final String sheetTemplateId;

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('sheetTemplateId', sheetTemplateId));
  }

  @override
  ConsumerState<HeaderManagementPage> createState() =>
      _HeaderManagementPageState();
}

class _HeaderManagementPageState extends ConsumerState<HeaderManagementPage> {
  @override
  void initState() {
    super.initState();
    unawaited(
      Future<void>.microtask(
        () => ref
            .read(headerManagementNotifierProvider.notifier)
            .load(widget.sheetTemplateId),
      ),
    );
  }

  Future<void> _showErrorIfAny(final String? errorMessage) async {
    if (errorMessage == null || !mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(errorMessage)));
  }

  Future<void> _showHeaderForm({
    final Header? header,
    final int? currentPrice,
  }) async {
    final _HeaderFormResult? result = await showDialog<_HeaderFormResult>(
      context: context,
      builder: (final BuildContext context) =>
          _HeaderFormDialog(header: header, currentPrice: currentPrice),
    );
    if (result == null || !mounted) {
      return;
    }

    final HeaderManagementNotifier notifier = ref.read(
      headerManagementNotifierProvider.notifier,
    );
    final String? errorMessage = header == null
        ? await notifier.addHeader(
            name: result.name,
            category: result.category,
            price: result.price,
            isVisible: result.isVisible,
          )
        : await notifier.updateHeader(
            columnId: header.columnId,
            name: result.name,
            category: result.category,
            isVisible: result.isVisible,
            newPrice: result.price == currentPrice ? null : result.price,
          );
    await _showErrorIfAny(errorMessage);
  }

  @override
  Widget build(final BuildContext context) {
    final HeaderManagementState state = ref.watch(
      headerManagementNotifierProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('ヘッダー管理'),
            Text('MMM_003_VOUCHER', style: TextStyle(fontSize: 11)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showHeaderForm,
        child: const Icon(Icons.add),
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(final HeaderManagementState state) {
    switch (state.status) {
      case HeaderManagementStatus.initial:
      case HeaderManagementStatus.loading:
        return const LoadingIndicator();
      case HeaderManagementStatus.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(state.errorMessage ?? ''),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref
                    .read(headerManagementNotifierProvider.notifier)
                    .load(widget.sheetTemplateId),
                child: const Text('再試行'),
              ),
            ],
          ),
        );
      case HeaderManagementStatus.success:
        if (state.headers.isEmpty) {
          return const Center(child: Text('列が登録されていません'));
        }
        return ListView.builder(
          itemCount: state.headers.length,
          itemBuilder: (final BuildContext context, final int index) {
            final Header header = state.headers[index];
            final int? price = state.unitPricesByColumnId[header.columnId];
            return ListTile(
              title: Text(header.name),
              subtitle: Text(
                <String>[
                  _categoryLabels[header.category] ?? '未指定',
                  if (price == null) '単価未登録' else formatYen(price),
                  if (header.isVisible) '表示' else '非表示',
                ].join(' / '),
              ),
              onTap: () => _showHeaderForm(header: header, currentPrice: price),
            );
          },
        );
    }
  }
}

/// [_HeaderFormDialog] の入力結果。
class _HeaderFormResult {
  const _HeaderFormResult({
    required this.name,
    required this.category,
    required this.price,
    required this.isVisible,
  });

  final String name;
  final HeaderCategory category;
  final int price;
  final bool isVisible;
}

/// ヘッダーの追加・編集フォームダイアログ。
class _HeaderFormDialog extends StatefulWidget {
  const _HeaderFormDialog({this.header, this.currentPrice});

  final Header? header;
  final int? currentPrice;

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<Header?>('header', header))
      ..add(IntProperty('currentPrice', currentPrice));
  }

  @override
  State<_HeaderFormDialog> createState() => _HeaderFormDialogState();
}

class _HeaderFormDialogState extends State<_HeaderFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late HeaderCategory _category;
  late bool _isVisible;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.header?.name ?? '');
    _priceController = TextEditingController(
      text: widget.currentPrice?.toString() ?? '',
    );
    _category = widget.header?.category ?? HeaderCategory.none;
    _isVisible = widget.header?.isVisible ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submit() {
    final int? price = int.tryParse(_priceController.text);
    if (_nameController.text.trim().isEmpty || price == null) {
      return;
    }
    Navigator.of(context).pop(
      _HeaderFormResult(
        name: _nameController.text,
        category: _category,
        price: price,
        isVisible: _isVisible,
      ),
    );
  }

  @override
  Widget build(final BuildContext context) => AlertDialog(
        title: Text(widget.header == null ? '列を追加' : '列を編集'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: const InputDecoration(labelText: '項目'),
            ),
            DropdownButtonFormField<HeaderCategory>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'カテゴリー'),
              items: _categoryLabels.entries
                  .map(
                    (final MapEntry<HeaderCategory, String> entry) =>
                        DropdownMenuItem<HeaderCategory>(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                  )
                  .toList(),
              onChanged: (final HeaderCategory? value) {
                if (value == null) {
                  return;
                }
                setState(() => _category = value);
              },
            ),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '価格'),
            ),
            SwitchListTile(
              title: const Text('表示する'),
              value: _isVisible,
              onChanged: (final bool value) =>
                  setState(() => _isVisible = value),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(onPressed: _submit, child: const Text('保存')),
        ],
      );
}
