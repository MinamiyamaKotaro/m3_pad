import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../controllers/csv_export_range_notifier.dart';
import '../controllers/csv_export_range_state.dart';

/// CSV出力画面（画面ID: `MMM_005_VOUCHER`）。
///
/// 開始日〜終了日を指定し、期間内の全営業日分の伝票データを1つのCSVとして
/// まとめて出力する（FR-3）。
class CsvExportRangePage extends ConsumerStatefulWidget {
  /// [CsvExportRangePage] を生成する。
  const CsvExportRangePage({required this.sheetTemplateId, super.key});

  /// 対象の伝票フォーマットID。
  final String sheetTemplateId;

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('sheetTemplateId', sheetTemplateId));
  }

  @override
  ConsumerState<CsvExportRangePage> createState() => _CsvExportRangePageState();
}

class _CsvExportRangePageState extends ConsumerState<CsvExportRangePage> {
  static const List<String> _weekdayNames = <String>[
    '月',
    '火',
    '水',
    '木',
    '金',
    '土',
    '日',
  ];

  @override
  void initState() {
    super.initState();
    ref.read(csvExportRangeNotifierProvider.notifier).init(
          widget.sheetTemplateId,
        );
  }

  String _formatDate(final DateTime? date) {
    if (date == null) {
      return '未選択';
    }
    final String weekday = _weekdayNames[date.weekday - 1];
    return '${date.year}年${date.month}月${date.day}日 $weekday曜日';
  }

  Future<void> _pickDate({
    required final DateTime? initialDate,
    required final ValueChanged<DateTime> onPicked,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) {
      return;
    }
    onPicked(picked);
  }

  Future<void> _export() async {
    final CsvExportResult result =
        await ref.read(csvExportRangeNotifierProvider.notifier).export();
    if (!mounted) {
      return;
    }
    if (result.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.errorMessage!)));
      return;
    }
    await SharePlus.instance.share(ShareParams(text: result.csvContent));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('CSV出力が完了しました')));
  }

  @override
  Widget build(final BuildContext context) {
    final CsvExportRangeState state = ref.watch(csvExportRangeNotifierProvider);
    final CsvExportRangeNotifier notifier = ref.read(
      csvExportRangeNotifierProvider.notifier,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('CSV出力'),
            Text('MMM_005_VOUCHER', style: TextStyle(fontSize: 11)),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
              title: const Text('開始日'),
              subtitle: Text(_formatDate(state.from)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickDate(
                initialDate: state.from,
                onPicked: notifier.setFrom,
              ),
            ),
            ListTile(
              title: const Text('終了日'),
              subtitle: Text(_formatDate(state.to)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickDate(
                initialDate: state.to,
                onPicked: notifier.setTo,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: state.isExporting ? null : _export,
              child: state.isExporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('出力'),
            ),
          ],
        ),
      ),
    );
  }
}
