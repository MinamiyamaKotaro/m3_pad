# SheetCellModel（sheet_cell_model.dart）

| 新規作成・更新日 | 作成・更新者名 | 作成・更新内容 |
|---|---|---|
| 2026-09-25 | minamiyama | 新規作成 |

## 概要

[SheetCell](../../domain/entities/sheet_cell.md)のデータ層表現。SQLiteの行（`Map<String, dynamic>`）と相互変換する`fromMap`/`toMap`を持つ。`SheetCellModel extends SheetCell`として定義し、フィールド定義はエンティティを継承するため本ドキュメントでは重複記載しない（項目定義は[SheetCell](../../domain/entities/sheet_cell.md)を参照）。[SheetCellLocalDataSource](../datasources/sheet_cell_local_datasource.md)・[SheetCellRepositoryImpl](../repositories/sheet_cell_repository_impl.md)が使用する。

## 依存関係シーケンス図

```mermaid
classDiagram
    SheetCellModel --|> SheetCell : extends
    SheetCellLocalDataSource --> SheetCellModel : creates
    SheetCellRepositoryImpl --> SheetCellModel : uses
```

## fromMap

### 処理概要
SQLiteの行（`Map<String, dynamic>`）から`SheetCellModel`を生成する。

### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| DB行データ | map | map | string(key), dynamic(value) | 必須 | `t_cell`テーブルの1行分 |

### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| モデル | - | - | SheetCellModel | - |

### exception

なし

### 処理詳細
1. `map['cell_id']`→`cellId`、`map['row_id']`→`rowId`、`map['column_id']`→`columnId`、`map['content']`（`null`許容）→`content`、`map['quantity']`（`null`許容）→`quantity`、`map['unit_price_applied']`（`null`許容）→`unitPriceApplied`、`map['amount']`（`null`許容）→`amount`、`map['created_at']`/`map['updated_at']`→DateTimeへ変換してそれぞれ対応付け、`SheetCellModel`を生成する。
2. 生成したインスタンスを返却する。

## toMap

### 処理概要
`SheetCellModel`をSQLiteへ保存可能な`Map<String, dynamic>`に変換する。

### input

なし（自身のフィールドを使用する）

### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| DB行データ | - | map | string(key), dynamic(value) | `null`許容フィールドはそのまま`null`を格納可能。日時はISO8601文字列に変換する |

### exception

なし

### 処理詳細
1. 各フィールドをDBの物理カラム名（snake_case）をキーとした`Map`に変換する。
2. 変換した`Map`を返却する。
