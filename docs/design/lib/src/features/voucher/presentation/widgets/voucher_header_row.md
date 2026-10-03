# VoucherHeaderRow（voucher_header_row.dart）

| 新規作成・更新日 | 作成・更新者名 | 作成・更新内容 |
|---|---|---|
| 2026-09-25 | minamiyama | 新規作成 |
| 2026-09-29 | minamiyama | [docs/ui/wireframe](../../../../../../../ui/wireframe/style.css)を正として、各列の右罫線に加え下罫線を追加し、罫線色を`colorScheme.outline`（wireframeの`--color-border`相当）に統一。[VoucherSheetGrid](./voucher_sheet_grid.md)内で価格列＋MEMO列部分のヘッダーとして使用するよう変更 |
| 2026-09-29 | minamiyama | 列名の文字数に関わらずヘッダーの高さを統一するため、`Row`の`crossAxisAlignment`を`stretch`に変更（各列のセルが親の高さいっぱいに広がり、文字列を縦方向中央揃えで表示する） |
| 2026-09-29 | minamiyama | 単価表示を[currency_format](../../../../core/utils/currency_format.md)の`formatYen`による3桁区切りカンマ付き表示に変更 |
| 2026-09-29 | minamiyama | ヘッダー管理機能（FR-6）に伴い、(1)現在の単価が同額の隣接列を1セル内に改行してまとめて表示するグルーピング表示、(2)[HeaderCategory](../../domain/entities/enums/header_category.md)ごとの背景色分け、を追加。非表示列（`isVisible=false`）の除外は呼び出し元（[VoucherSheetGrid](./voucher_sheet_grid.md)）が行うようになり、本ウィジェットは表示対象の列のみを受け取る想定に変更（項目一覧の備考を更新） |
| 2026-09-29 | minamiyama | 同額グルーピングが隣接列同士でしか成立していなかった不具合を修正するため、列の並べ替え（同額の列を隣接させる処理）を[VoucherSheetGrid](./voucher_sheet_grid.md)側へ移動（本ウィジェットは受け取った順序のまま隣接する同額列をまとめるのみ）。あわせて、色分けを背景色から文字色に変更し、列名を（カテゴリーによらず）全て太字表示に変更 |
| 2026-10-03 | minamiyama | 引数を列一覧（`headers`）から列グループ一覧（`headerGroups`、[header_grouping](../../domain/usecases/header_grouping.md)の戻り値）に変更し、グルーピングを呼び出し元に一本化。列名をグループ先頭ではなく各列のカテゴリーの文字色で表示し、複数のカテゴリーが混在するグループの単価を黒色で表示するよう変更 |

## 概要

伝票入力画面（[VoucherSheetPage](../pages/voucher_sheet_page.md)、`MMM_001_VOUCHER`）のグリッド（[VoucherSheetGrid](./voucher_sheet_grid.md)）内で、価格列＋MEMO列部分の列名・単価を表示するヘッダー行ウィジェット。紙伝票のヘッダー行固定表示（[requirements.md](../../../../../../../requried/requirements.md) FR-1）に対応する。現在の単価が同額の列のグループごとに1セルを描画して列名を改行表示し、列ごとにカテゴリーの文字色を変える（背景色は変えない、FR-6）。列名はカテゴリーによらず全て太字で表示する。「お名前」「合計金額」「担当」の各見出しは[VoucherSheetGrid](./voucher_sheet_grid.md)側で描画するため含まない。画面内でのみ使用する。

## 依存関係シーケンス図

```mermaid
classDiagram
    VoucherSheetGrid --> VoucherHeaderRow : uses
    VoucherHeaderRow --> Header : headerGroups
    VoucherHeaderRow --> HeaderCategory : category色分け
```

## 項目一覧（コンストラクタ引数）

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 列グループ一覧 | headerGroups | list(list) | [Header](../../domain/entities/header.md) | 必須 | 表示対象（`isVisible=true`）の列を[groupHeadersByPrice](../../domain/usecases/header_grouping.md#groupheadersbyprice)で同額ごとにまとめたもの（描画順）。グループごとに1セルを描画する |
| 列ID別の現在の適用単価Map | unitPricesByColumnId | map | string(key), int(value) | 必須 | `SheetDetail.unitPricesByColumnId`。単価表示に使用する（グループ先頭の列の単価） |

## 表示ルール

- `headerGroups`のグループごとに、幅`96px（columnWidth） × グループ内列数`の1セルを描画し、グループ内の列名を改行して表示する。単価はグループ先頭の列の値を1つのみ表示する（単価未登録・非価格対象の場合は表示しない）。グループの組み立て・並び順は呼び出し元（[VoucherSheetGrid](./voucher_sheet_grid.md)）が行う。
- 列名の文字色は、**各列**の[HeaderCategory](../../domain/entities/enums/header_category.md)に応じて変える（`drink`＝青系、`bottle`＝紫系、`food`＝緑系、`none`＝既定の文字色）。背景色は変えない。
- 単価の文字色は、グループ内のカテゴリーが1種類の場合はそのカテゴリーの文字色、**複数のカテゴリーが混在する場合は黒色**（`colorScheme.onSurface`）とする。
- 列名・単価は、カテゴリーによらず全て太字（`FontWeight.bold`）で表示する。
- 各セルの右側・下側に罫線（`colorScheme.outline`）を表示する。
- 各セルは、列名の文字数（折り返し行数）に関わらず高さを統一する（親から与えられた高さいっぱいに広がり、文字列は縦方向中央揃え）。
