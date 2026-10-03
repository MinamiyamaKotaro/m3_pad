# VoucherCellField（voucher_cell_field.dart）

| 新規作成・更新日 | 作成・更新者名 | 作成・更新内容 |
|---|---|---|
| 2026-09-25 | minamiyama | 新規作成 |
| 2026-09-29 | minamiyama | [VoucherSheetGrid](./voucher_sheet_grid.md)導入に伴い、使用元を旧`VoucherDataRow`から[VoucherSheetGrid](./voucher_sheet_grid.md)に変更 |
| 2026-09-29 | minamiyama | `isPriced=true`（MEMO以外）の列について、テキスト入力（数値キーボード）から数量の増減ボタン（スピンボタン）方式に変更。MEMO列（`isPriced=false`）は従来どおりタップして編集するテキスト入力のまま |
| 2026-09-29 | minamiyama | MEMO列の非編集時テキストのスタイルを、[VoucherSheetGrid](./voucher_sheet_grid.md)の行高さ算出（`TextPainter`によるMEMO内容の折り返し計測）と一致させるため、`Theme.textTheme.bodyMedium`を明示指定するよう変更（従来は`style: null`でアンビエントな既定スタイルに依存していた） |
| 2026-10-03 | minamiyama | 個数セルを同額の列のグループにつき1つにするため、増減ボタン（スピンボタン）の表示を[VoucherQuantityCell](./voucher_quantity_cell.md)へ分離。本ウィジェットはMEMO列（`isPriced=false`）専用のテキスト入力とした |

## 概要

[VoucherSheetGrid](./voucher_sheet_grid.md)内で、MEMO列（`isPriced=false`の列）の1セル分の入力を表すウィジェット。タップして編集するテキスト入力を表示する。価格対象の列の個数セルは、同額の列のグループ単位で[VoucherQuantityCell](./voucher_quantity_cell.md)が表示する。画面内でのみ使用する。

## 依存関係シーケンス図

```mermaid
classDiagram
    VoucherSheetGrid --> VoucherCellField : uses
    VoucherCellField --> Header : header
    VoucherCellField --> SheetCell : cell
```

## 項目一覧（コンストラクタ引数）

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 列 | header | - | [Header](../../domain/entities/header.md) | 必須 | MEMO列（`isPriced=false`） |
| セル | cell | optional | [SheetCell](../../domain/entities/sheet_cell.md) | 任意 | 未入力の場合は`null`。表示値なし（「–」）として描画する |
| 編集中フラグ | isEditing | - | bool | 必須 | `true`の場合、テキスト入力欄を表示する |
| 編集中の入力テキスト | editingText | optional | string | `isEditing=true`の場合のみ使用 | MEMO列でのみ使用 |
| タップ時コールバック | onTap | - | function() -> void | 必須 | 親（[VoucherSheetGrid](./voucher_sheet_grid.md)）の`onCellTap`へ列IDと現在の表示値を渡して呼び出す |
| テキスト変更時コールバック | onChanged | - | function(text: string) -> void | 必須 | 親の`onTextChanged`をそのまま呼び出す |
| 入力確定時コールバック | onSubmitted | - | function() -> void | 必須 | 親の`onCommit`をそのまま呼び出す |

## 表示ルール

- 非編集時は`cell?.content`（未入力は「–」）を表示し、タップでテキスト入力欄に切り替わる。
