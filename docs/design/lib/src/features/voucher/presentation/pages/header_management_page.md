# HeaderManagementPage（header_management_page.dart）

| 新規作成・更新日 | 作成・更新者名 | 作成・更新内容 |
|---|---|---|
| 2026-09-29 | minamiyama | 新規作成（ヘッダー管理機能、FR-6） |

## 画面ID

`MMM_003_VOUCHER`

## 処理概要

ヘッダー管理画面。「お名前」「MEMO」「合計金額」「担当」以外の価格対象の列（項目名・カテゴリー・単価・表示/非表示）を追加・編集する（FR-6）。[SettingsMenuPage](./settings_menu_page.md)から`sheetTemplateId`を受け取って遷移する。画面全体の土台（Scaffold）を配置し、[HeaderManagementState](../controllers/header_management_state.md)を監視（watch）して状態に応じた子ウィジェットを表示する。

## 項目一覧（コンストラクタ引数）

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 対象の伝票フォーマットID | sheetTemplateId | - | string | 必須 | [HeaderManagementNotifier.load](../controllers/header_management_notifier.md#load)に渡す |

## 状態に応じた表示切り替え

| [HeaderManagementState.status](../controllers/header_management_state.md) | 表示内容 |
|---|---|
| initial / loading | [LoadingIndicator](../../../../core/widgets/loading_indicator.md)を画面中央に表示する |
| error | `errorMessage`と「再試行」ボタンを画面中央に表示する。ボタン押下で[HeaderManagementNotifier.load](../controllers/header_management_notifier.md#load)を呼び出す |
| success（列0件） | 「列が登録されていません」の案内文言を画面中央に表示する |
| success（1件以上） | `headers`を`ListView`で一覧表示する。各行にカテゴリー・単価（未登録の場合「単価未登録」）・表示/非表示を表示し、タップで編集フォームを開く |

## 副作用の処理

[HeaderManagementNotifier](../controllers/header_management_notifier.md)の追加/更新メソッドは戻り値（成功時`null`、失敗時はエラーメッセージ文字列）で結果を返す設計のため、1回限りのEffectチャネルは使用しない。呼び出し元（`_showHeaderForm`）で戻り値がエラーメッセージの場合、`ScaffoldMessenger.showSnackBar`で表示する。

## 子コンポーネント（Widgets）の分割定義

| ウィジェット | 役割 |
|---|---|
| `_HeaderFormDialog`（`AlertDialog`） | ヘッダーの追加・編集フォーム。項目名（`TextField`）・カテゴリー（`DropdownButtonFormField`）・価格（`TextField`、数値キーボード）・表示/非表示（`SwitchListTile`）を入力する。`header`引数が`null`の場合は追加、非`null`の場合は編集として、各値に既存値（`currentPrice`含む）を初期表示する。保存時は`_HeaderFormResult`（`name`・`category`・`price`・`isVisible`）を`Navigator.pop`で返す |

## 共通UIコンポーネントの利用

- [LoadingIndicator](../../../../core/widgets/loading_indicator.md)（`src/core/widgets/`）: loading状態の表示に使用する。
- [currency_format.formatYen](../../../../core/utils/currency_format.md)（`src/core/utils/`）: 単価の3桁区切り表示に使用する。

## AppBarの構成

- タイトル: 「ヘッダー管理」＋画面ID「MMM_003_VOUCHER」の2段表示。
- `floatingActionButton`（`Icons.add`）押下で追加フォームダイアログを表示する。

## 編集時の単価未変更判定

編集フォームで保存した`price`が、開いた時点の`currentPrice`（一覧表示中の現在単価）と同じ場合は、[HeaderManagementNotifier.updateHeader](../controllers/header_management_notifier.md#updateheader)へ`newPrice=null`を渡し、価格改定処理（[HeaderPriceRepository](../../domain/repositories/header_price_repository.md)への書き込み）をスキップする。異なる場合のみ`newPrice`に保存値を渡す。
