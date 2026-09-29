# CsvExportRangePage（csv_export_range_page.dart）

| 新規作成・更新日 | 作成・更新者名 | 作成・更新内容 |
|---|---|---|
| 2026-09-29 | minamiyama | 新規作成（CSV期間出力機能、FR-3） |

## 画面ID

`MMM_005_VOUCHER`

## 処理概要

CSV出力画面。開始日〜終了日を指定し、期間内の全営業日分の伝票データを1つのCSVとしてまとめて出力する（FR-3）。[SettingsMenuPage](./settings_menu_page.md)から`sheetTemplateId`を受け取って遷移する。画面全体の土台（Scaffold）を配置し、[CsvExportRangeState](../controllers/csv_export_range_state.md)を監視（watch）する。

## 項目一覧（コンストラクタ引数）

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 対象の伝票フォーマットID | sheetTemplateId | - | string | 必須 | [CsvExportRangeNotifier.init](../controllers/csv_export_range_notifier.md#init)に渡す |

## UI構成

| プロパティ | 表示内容 |
|---|---|
| `state.from` | 「開始日」`ListTile`。「YYYY年M月D日 X曜日」形式（未選択時「未選択」）。タップで`showDatePicker`を表示し、選択結果を[CsvExportRangeNotifier.setFrom](../controllers/csv_export_range_notifier.md#setfrom--setto)へ渡す |
| `state.to` | 「終了日」`ListTile`。表示・操作は開始日と同様（[CsvExportRangeNotifier.setTo](../controllers/csv_export_range_notifier.md#setfrom--setto)へ渡す） |
| `state.isExporting` | 「出力」`ElevatedButton`。`true`の間はボタンをインジケータ表示に切り替え、`onPressed`を`null`にして多重押下を防止する |

## 副作用の処理

[CsvExportRangeNotifier.export](../controllers/csv_export_range_notifier.md#export)の戻り値（[CsvExportResult](../controllers/csv_export_range_state.md)）に応じて、`_export`メソッドが以下を行う。

| 結果 | UI側の処理 |
|---|---|
| `errorMessage`が非`null`（失敗） | `errorMessage`を`ScaffoldMessenger.showSnackBar`で表示する |
| `csvContent`が非`null`（成功） | `SharePlus.instance.share`でOS標準の共有シート（Share）に`csvContent`を渡す。完了後「CSV出力が完了しました」を`SnackBar`で表示する |

## AppBarの構成

- タイトル: 「CSV出力」＋画面ID「MMM_005_VOUCHER」の2段表示。
