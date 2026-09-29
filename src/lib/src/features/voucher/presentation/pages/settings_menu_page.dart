import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'csv_export_range_page.dart';
import 'header_management_page.dart';
import 'staff_management_page.dart';

/// 設定メニュー画面（画面ID: `MMM_002_VOUCHER`）。
///
/// 伝票入力画面右上の設定アイコンから遷移する、設定機能（FR-6・FR-7・
/// CSV期間出力）への入口となる画面。「ヘッダー管理」「スタッフ管理」
/// 「CSV出力」の3項目から各画面へ遷移する。
class SettingsMenuPage extends StatelessWidget {
  /// [SettingsMenuPage] を生成する。
  const SettingsMenuPage({required this.sheetTemplateId, super.key});

  /// 対象の伝票フォーマットID。ヘッダー管理・CSV出力画面へそのまま渡す。
  final String sheetTemplateId;

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('sheetTemplateId', sheetTemplateId));
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('設定'),
              Text('MMM_002_VOUCHER', style: TextStyle(fontSize: 11)),
            ],
          ),
        ),
        body: ListView(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.view_column),
              title: const Text('ヘッダー管理'),
              subtitle: const Text('列の項目・カテゴリー・価格・表示/非表示'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (final BuildContext context) =>
                      HeaderManagementPage(sheetTemplateId: sheetTemplateId),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('スタッフ管理'),
              subtitle: const Text('スタッフの追加・編集・削除'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (final BuildContext context) =>
                      const StaffManagementPage(),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.ios_share),
              title: const Text('CSV出力'),
              subtitle: const Text('期間を指定して伝票データを出力'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (final BuildContext context) =>
                      CsvExportRangePage(sheetTemplateId: sheetTemplateId),
                ),
              ),
            ),
          ],
        ),
      );
}
