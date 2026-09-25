# SheetCellRepository（sheet_cell_repository.dart）

| 新規作成・更新日 | 作成・更新者名 | 作成・更新内容 |
|---|---|---|
| 2026-09-25 | minamiyama | 新規作成（domain層インターフェースとして定義） |

## 概要

[SheetCell](../entities/sheet_cell.md)に対する永続化・検索・更新の契約のみを定義する抽象クラス。実装は[SheetCellRepositoryImpl](../../data/repositories/sheet_cell_repository_impl.md)が担う。[InputCellUsecase](../usecases/input_cell_usecase.md)・[ExportDailySheetToCsvUsecase](../usecases/export_daily_sheet_to_csv_usecase.md)が依存する。

## メソッド一覧

### findByRowAndColumn

| 項目 | 内容 |
|---|---|
| シグネチャ | `Future<SheetCell?> findByRowAndColumn(String rowId, String columnId)` |

#### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 行ID | rowId | - | string | 必須 | - |
| 列ID | columnId | - | string | 必須 | - |

#### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| セル | - | optional | [SheetCell](../entities/sheet_cell.md) | 未入力の場合は`null` |

#### exception

なし

### insert

| 項目 | 内容 |
|---|---|
| シグネチャ | `Future<void> insert(SheetCell cell)` |

#### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| セル | cell | - | [SheetCell](../entities/sheet_cell.md) | 必須 | - |

#### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| - | - | - | void | - |

#### exception

なし

### update

| 項目 | 内容 |
|---|---|
| シグネチャ | `Future<void> update(SheetCell cell)` |

#### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| セル | cell | - | [SheetCell](../entities/sheet_cell.md) | 必須, `cellId`が既存レコードと一致すること | - |

#### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| - | - | - | void | - |

#### exception

なし

### findByRowId

| 項目 | 内容 |
|---|---|
| シグネチャ | `Future<List<SheetCell>> findByRowId(String rowId)` |

#### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 行ID | rowId | - | string | 必須 | - |

#### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| セル一覧 | - | list | [SheetCell](../entities/sheet_cell.md) | 該当なしの場合は空リスト |

#### exception

なし

### findByRowIds

| 項目 | 内容 |
|---|---|
| シグネチャ | `Future<List<SheetCell>> findByRowIds(List<String> rowIds)` |

#### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 行IDリスト | rowIds | list | string | 必須, 1件以上 | 複数行分のセルを1回のSQLで一括取得するために使用（繰り返し内でのDB呼び出し回避） |

#### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| セル一覧 | - | list | [SheetCell](../entities/sheet_cell.md) | 該当なしの場合は空リスト |

#### exception

なし
