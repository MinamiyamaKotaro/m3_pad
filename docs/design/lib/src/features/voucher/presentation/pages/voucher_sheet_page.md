# VoucherSheetPage（voucher_sheet_page.dart）

| 新規作成・更新日 | 作成・更新者名 | 作成・更新内容 |
|---|---|---|
| 2026-09-25 | minamiyama | 新規作成 |
| 2026-09-27 | minamiyama | [VoucherStaffBar](../widgets/voucher_staff_bar.md)（タイトルヘッダーと表のヘッダーの間）、[VoucherDailySummaryRow](../widgets/voucher_daily_summary_row.md)（伝票末尾の行）、[VoucherAddRowButton](../widgets/voucher_add_row_button.md)（表内・本日の合計行の一つ前の行）を追加し、行追加ボタンをFloatingActionButtonから表内へ変更（[agents.md](../../../../../../../requried/agents.md)を反映） |
| 2026-09-29 | minamiyama | [docs/ui/wireframe](../../../../../../../ui/wireframe/app.js)を正として、表本体の描画を[VoucherSheetGrid](../widgets/voucher_sheet_grid.md)（縦横スクロール時の固定表示に対応）へ置き換え。AppBarに「寿」マーク（[VoucherStaffBar](../widgets/voucher_staff_bar.md)と同じ配色）・「MMM_001_VOUCHER」サブタイトル・営業日（月/日）表示を追加 |

## 画面ID

`MMM_001_VOUCHER`

## 処理概要

伝票入力画面。紙伝票（[docs/ui/ui.pdf](../../../../../../../ui/ui.pdf)「寿」フォーマット）と同じ列構成・ヘッダー固定表示を再現し、来店・卓ごとの行入力、金額の自動計算表示、スタッフ欄・日次集計の表示、CSV出力を行う（FR-1〜FR-3）。画面全体の土台（Scaffold）を配置し、[VoucherSheetState](../controllers/voucher_sheet_state.md)を監視（watch）して状態に応じた子ウィジェットを表示する。[VoucherSheetNotifier](../controllers/voucher_sheet_notifier.md)からの[VoucherSheetEffect](../controllers/voucher_sheet_effect.md)を購読（listen）し、画面上部のお知らせ表示・共有シート表示等の副作用を処理する。

## 状態に応じた表示切り替え

| [VoucherSheetState.status](../controllers/voucher_sheet_state.md) | 表示内容 |
|---|---|
| initial / loading | [LoadingIndicator](../../../../core/widgets/loading_indicator.md)を画面中央に表示する |
| error | `errorMessage`と「再試行」ボタンを画面中央に表示する。ボタン押下で[VoucherSheetNotifier.retry](../controllers/voucher_sheet_notifier.md#retry)を呼び出す |
| empty | 「まだ行がありません」等の案内文言と「行を追加」ボタンを画面中央に表示する |
| success | AppBarの直下に[VoucherStaffBar](../widgets/voucher_staff_bar.md)を配置し、その下に[VoucherSheetGrid](../widgets/voucher_sheet_grid.md)を表示する。[VoucherSheetGrid](../widgets/voucher_sheet_grid.md)はヘッダー行・データ行（`sheetDetail.rows`の件数分）・行を追加ボタン・本日の合計行を、ヘッダー行/本日の合計行/お名前列/合計金額列/担当列を固定表示した縦・横スクロール可能なグリッドとして表示する |

## 副作用（Side Effect）の処理

[VoucherSheetEffect](../controllers/voucher_sheet_effect.md)を`ref.listen`相当で購読し、以下のとおり処理する。

| [VoucherSheetEffect.kind](../controllers/voucher_sheet_effect.md) | UI側の処理 |
|---|---|
| cellInputFailed | `message`を[NoticeBanner](../../../../core/widgets/notice_banner.md)（`tone=error`）として画面上部に表示する |
| exportSucceeded | `csvContent`をOS標準の共有シート（Share）に渡す。あわせて`message`を[NoticeBanner](../../../../core/widgets/notice_banner.md)（`tone=success`）として画面上部に表示する |
| exportFailed | `message`を[NoticeBanner](../../../../core/widgets/notice_banner.md)（`tone=error`）として画面上部に表示する |

## 子コンポーネント（Widgets）の分割定義

| ウィジェット | 役割 |
|---|---|
| [VoucherStaffBar](../widgets/voucher_staff_bar.md) | 右上「スタッフ」欄（氏名・就業時刻・ドリンクバック）。タイトルヘッダーと表のヘッダーの間に固定表示する |
| [VoucherSheetGrid](../widgets/voucher_sheet_grid.md) | 表本体。ヘッダー行・データ行・行を追加ボタン・本日の合計行を、固定表示を含む縦横スクロール可能なグリッドとして表示する |
| [VoucherHeaderRow](../widgets/voucher_header_row.md) | [VoucherSheetGrid](../widgets/voucher_sheet_grid.md)内で使用する、列名・単価のヘッダー行（価格列＋MEMO列部分） |
| [VoucherNameCell](../widgets/voucher_name_cell.md) | [VoucherSheetGrid](../widgets/voucher_sheet_grid.md)内の1行分の「お名前」列セル（-様＋NEWマーク表示を含む） |
| [VoucherCellField](../widgets/voucher_cell_field.md) | [VoucherSheetGrid](../widgets/voucher_sheet_grid.md)内の1セル分の入力欄。列の`isPriced`に応じて数量入力／テキスト入力を切り替える |
| [VoucherTotalCell](../widgets/voucher_total_cell.md) | [VoucherSheetGrid](../widgets/voucher_sheet_grid.md)内の1行分の「合計金額」列セル（決済方法トグル付き） |
| [VoucherStaffSelectCell](../widgets/voucher_staff_select_cell.md) | [VoucherSheetGrid](../widgets/voucher_sheet_grid.md)内の1行分の「担当」列セル（プルダウン） |
| [VoucherAddRowButton](../widgets/voucher_add_row_button.md) | 「行を追加」ボタン。[VoucherSheetGrid](../widgets/voucher_sheet_grid.md)の「お名前」列固定領域内、データ行一覧の最後に配置する |
| [VoucherDailySummaryRow](../widgets/voucher_daily_summary_row.md) | 本日の合計行のうち「合計金額」列セル。その日の合計金額と決済方法別内訳を表示する |

## 共通UIコンポーネントの利用

- [LoadingIndicator](../../../../core/widgets/loading_indicator.md)（`src/core/widgets/`）: loading状態の表示に使用する。
- [NoticeBanner](../../../../core/widgets/notice_banner.md)（`src/core/widgets/`）: 副作用（Side Effect）発生時に画面上部のお知らせ表示に使用する。

## AppBarの構成

- 先頭（leading）: 紙伝票フォーマット名の丸バッジ（`CircleAvatar`、背景・文字色は`colorScheme.onPrimary`/`colorScheme.primary`でAppBarの配色と反転させる）。
- タイトル: 「伝票入力」＋画面ID「MMM_001_VOUCHER」の2段表示。
- アクション: 営業日（`businessDate`の月/日、表示のみ・編集不可）、CSV出力ボタン。CSV出力ボタン押下で[VoucherSheetNotifier.exportCsv](../controllers/voucher_sheet_notifier.md#exportcsv)を呼び出す。`isExporting=true`の間はボタンをインジケータ表示に切り替え、多重押下を防止する。
- 配色: `AppBarTheme`（`backgroundColor`/`foregroundColor`）により、[docs/ui/wireframe](../../../../../../../ui/wireframe/style.css)の`--color-primary`/`--color-primary-contrast`と同じ配色（黒背景・オフホワイト文字）とする。

## 行追加ボタンの配置

- success状態: [VoucherAddRowButton](../widgets/voucher_add_row_button.md)を[VoucherSheetGrid](../widgets/voucher_sheet_grid.md)の「お名前」列固定領域内、データ行一覧の最後（本日の合計行の一つ前）に配置する。押下で[VoucherSheetNotifier.addRow](../controllers/voucher_sheet_notifier.md#addrow)を呼び出す。画面右下のFloatingActionButtonは使用しない（横スクロール時にボタンを見失わないよう、「お名前」列と同じ固定領域に置くことで水平方向は常に視認できるようにする）。
- empty状態: 画面中央の案内文言に添えたボタン（[状態に応じた表示切り替え](#状態に応じた表示切り替え)参照）を使用する。押下で同じく[VoucherSheetNotifier.addRow](../controllers/voucher_sheet_notifier.md#addrow)を呼び出す。
