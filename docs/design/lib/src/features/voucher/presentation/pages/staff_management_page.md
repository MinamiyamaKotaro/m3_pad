# StaffManagementPage（staff_management_page.dart）

| 新規作成・更新日 | 作成・更新者名 | 作成・更新内容 |
|---|---|---|
| 2026-09-29 | minamiyama | 新規作成（スタッフ管理機能、FR-7） |

## 画面ID

`MMM_004_VOUCHER`

## 処理概要

スタッフ管理画面。スタッフの氏名を追加・編集・削除（論理削除）する（FR-7）。[SettingsMenuPage](./settings_menu_page.md)から遷移する。画面全体の土台（Scaffold）を配置し、[StaffManagementState](../controllers/staff_management_state.md)を監視（watch）して状態に応じた子ウィジェットを表示する。

## 状態に応じた表示切り替え

| [StaffManagementState.status](../controllers/staff_management_state.md) | 表示内容 |
|---|---|
| initial / loading | [LoadingIndicator](../../../../core/widgets/loading_indicator.md)を画面中央に表示する |
| error | `errorMessage`と「再試行」ボタンを画面中央に表示する。ボタン押下で[StaffManagementNotifier.load](../controllers/staff_management_notifier.md#load)を呼び出す |
| success（スタッフ0件） | 「スタッフが登録されていません」の案内文言を画面中央に表示する |
| success（1件以上） | `staffRoster`を`ListView`で一覧表示する。各行に氏名・編集アイコン・削除アイコンを表示する |

## 副作用の処理

[StaffManagementNotifier](../controllers/staff_management_notifier.md)の追加/編集/削除メソッドは戻り値（成功時`null`、失敗時はエラーメッセージ文字列）で結果を返す設計のため、[VoucherSheetPage](./voucher_sheet_page.md)のような1回限りのEffectチャネルは使用しない。呼び出し元（ダイアログのコールバック）で戻り値がエラーメッセージの場合、`ScaffoldMessenger.showSnackBar`で表示する。

## 子コンポーネント（Widgets）の分割定義

| ウィジェット | 役割 |
|---|---|
| `_showStaffForm`ダイアログ（`AlertDialog`＋`TextField`） | スタッフの追加・編集フォーム。`staff`引数が`null`の場合は追加、非`null`の場合は編集として、氏名入力欄に既存値を初期表示する |
| `_confirmRemove`ダイアログ（`AlertDialog`） | 削除確認ダイアログ。「削除」押下で[StaffManagementNotifier.removeStaff](../controllers/staff_management_notifier.md#removestaff)を呼び出す |

## 共通UIコンポーネントの利用

- [LoadingIndicator](../../../../core/widgets/loading_indicator.md)（`src/core/widgets/`）: loading状態の表示に使用する。

## AppBarの構成

- タイトル: 「スタッフ管理」＋画面ID「MMM_004_VOUCHER」の2段表示。
- `floatingActionButton`（`Icons.add`）押下で追加フォームダイアログを表示する。
