# VoucherHeaderRow（voucher_header_row.dart）

| 新規作成・更新日 | 作成・更新者名 | 作成・更新内容 |
|---|---|---|
| 2026-09-25 | minamiyama | 新規作成 |
| 2026-09-29 | minamiyama | [docs/ui/wireframe](../../../../../../../ui/wireframe/style.css)を正として、各列の右罫線に加え下罫線を追加し、罫線色を`colorScheme.outline`（wireframeの`--color-border`相当）に統一。[VoucherSheetGrid](./voucher_sheet_grid.md)内で価格列＋MEMO列部分のヘッダーとして使用するよう変更 |
| 2026-09-29 | minamiyama | 列名の文字数に関わらずヘッダーの高さを統一するため、`Row`の`crossAxisAlignment`を`stretch`に変更（各列のセルが親の高さいっぱいに広がり、文字列を縦方向中央揃えで表示する） |

## 概要

伝票入力画面（[VoucherSheetPage](../pages/voucher_sheet_page.md)、`MMM_001_VOUCHER`）のグリッド（[VoucherSheetGrid](./voucher_sheet_grid.md)）内で、価格列＋MEMO列部分の列名・単価を表示するヘッダー行ウィジェット。紙伝票のヘッダー行固定表示（[requirements.md](../../../../../../../requried/requirements.md) FR-1）に対応する。「お名前」「合計金額」「担当」の各見出しは[VoucherSheetGrid](./voucher_sheet_grid.md)側で描画するため含まない。画面内でのみ使用する。

## 依存関係シーケンス図

```mermaid
classDiagram
    VoucherSheetGrid --> VoucherHeaderRow : uses
    VoucherHeaderRow --> Header : headers
```

## 項目一覧（コンストラクタ引数）

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 列一覧 | headers | list | [Header](../../domain/entities/header.md) | 必須 | `displayOrder`昇順。列名と、`isPriced=true`の列は単価を表示する |

## 表示ルール

- 各列の右側・下側に罫線（`colorScheme.outline`）を表示する。
- 各列のセルは、列名の文字数（折り返し行数）に関わらず高さを統一する（親から与えられた高さいっぱいに広がり、文字列は縦方向中央揃え）。
