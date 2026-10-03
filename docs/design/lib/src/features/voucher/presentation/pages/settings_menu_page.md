# SettingsMenuPage（settings_menu_page.dart）

| 新規作成・更新日 | 作成・更新者名 | 作成・更新内容 |
|---|---|---|
| 2026-09-29 | minamiyama | 新規作成（設定機能の入口、FR-6・FR-7・FR-3） |

## 画面ID

`MMM_002_VOUCHER`

## 処理概要

設定メニュー画面。[VoucherSheetPage](./voucher_sheet_page.md)右上の設定アイコンから`Navigator.push`で遷移する、設定機能（FR-6・FR-7・CSV期間出力）への入口となる画面。状態管理を持たない`StatelessWidget`（一覧項目の固定表示とページ遷移のみのため、UiState・Notifierは不要）。

## 項目一覧（コンストラクタ引数）

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 対象の伝票フォーマットID | sheetTemplateId | - | string | 必須 | [HeaderManagementPage](./header_management_page.md)・[CsvExportRangePage](./csv_export_range_page.md)へそのまま渡す |

## UI構成

`ListView`に以下3項目を表示する。各項目タップで`Navigator.push`（`MaterialPageRoute`）により対象画面へ遷移する。

| 項目 | アイコン | 遷移先 |
|---|---|---|
| ヘッダー管理 | `Icons.view_column` | [HeaderManagementPage](./header_management_page.md)（`sheetTemplateId`を渡す） |
| スタッフ管理 | `Icons.people` | [StaffManagementPage](./staff_management_page.md) |
| CSV出力 | `Icons.ios_share` | [CsvExportRangePage](./csv_export_range_page.md)（`sheetTemplateId`を渡す） |

## AppBarの構成

- タイトル: 「設定」＋画面ID「MMM_002_VOUCHER」の2段表示。
