# VoucherSheetPage（voucher_sheet_page.dart）

| 新規作成・更新日 | 作成・更新者名 | 作成・更新内容 |
|---|---|---|
| 2026-09-25 | minamiyama | 新規作成 |
| 2026-09-27 | minamiyama | [VoucherStaffBar](../widgets/voucher_staff_bar.md)（タイトルヘッダーと表のヘッダーの間）、[VoucherDailySummaryRow](../widgets/voucher_daily_summary_row.md)（伝票末尾の行）、[VoucherAddRowButton](../widgets/voucher_add_row_button.md)（表内・本日の合計行の一つ前の行）を追加し、行追加ボタンをFloatingActionButtonから表内へ変更（[agents.md](../../../../../../../requried/agents.md)を反映） |

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
| success | AppBarの直下に[VoucherStaffBar](../widgets/voucher_staff_bar.md)を配置し、その下に[VoucherHeaderRow](../widgets/voucher_header_row.md)を画面上部に固定表示する。続けて[VoucherDataRow](../widgets/voucher_data_row.md)を`sheetDetail.rows`の件数分、[VoucherAddRowButton](../widgets/voucher_add_row_button.md)、[VoucherDailySummaryRow](../widgets/voucher_daily_summary_row.md)の順に、縦・横スクロール可能なグリッドとして表示する |

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
| [VoucherHeaderRow](../widgets/voucher_header_row.md) | 列名・単価をヘッダーとして固定表示する行 |
| [VoucherDataRow](../widgets/voucher_data_row.md) | 1組の来店・卓（[SheetRow](../../domain/entities/sheet_row.md)）を表す1行。お名前（-様＋NEWマーク）・担当スタッフ（プルダウン）・合計金額（決済方法トグル付き）の表示を含む |
| [VoucherCellField](../widgets/voucher_cell_field.md) | [VoucherDataRow](../widgets/voucher_data_row.md)内の1セル分の入力欄。列の`isPriced`に応じて数量入力／テキスト入力を切り替える |
| [VoucherAddRowButton](../widgets/voucher_add_row_button.md) | 「行を追加」ボタンを表す行。[VoucherDataRow](../widgets/voucher_data_row.md)一覧の最後、[VoucherDailySummaryRow](../widgets/voucher_daily_summary_row.md)の一つ前の行として表示する |
| [VoucherDailySummaryRow](../widgets/voucher_daily_summary_row.md) | 伝票末尾の行。その日の合計金額と決済方法別内訳を画面下部に固定表示する |

## 共通UIコンポーネントの利用

- [LoadingIndicator](../../../../core/widgets/loading_indicator.md)（`src/core/widgets/`）: loading状態の表示に使用する。
- [NoticeBanner](../../../../core/widgets/notice_banner.md)（`src/core/widgets/`）: 副作用（Side Effect）発生時に画面上部のお知らせ表示に使用する。

## AppBarのアクション

- CSV出力ボタン: 押下で[VoucherSheetNotifier.exportCsv](../controllers/voucher_sheet_notifier.md#exportcsv)を呼び出す。`isExporting=true`の間はボタンをインジケータ表示に切り替え、多重押下を防止する。

## 行追加ボタンの配置

- success状態: [VoucherAddRowButton](../widgets/voucher_add_row_button.md)を表内（[VoucherDailySummaryRow](../widgets/voucher_daily_summary_row.md)の一つ前の行）に配置する。押下で[VoucherSheetNotifier.addRow](../controllers/voucher_sheet_notifier.md#addrow)を呼び出す。画面右下のFloatingActionButtonは使用しない（横スクロール時にボタンを見失わないよう、行内でお名前列の右隣に水平方向のみ固定表示する。[VoucherAddRowButton](../widgets/voucher_add_row_button.md)参照）。
- empty状態: 画面中央の案内文言に添えたボタン（[状態に応じた表示切り替え](#状態に応じた表示切り替え)参照）を使用する。押下で同じく[VoucherSheetNotifier.addRow](../controllers/voucher_sheet_notifier.md#addrow)を呼び出す。
