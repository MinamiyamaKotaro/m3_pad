# SheetRowRepository（sheet_row_repository.dart）

| 新規作成・更新日 | 作成・更新者名 | 作成・更新内容 |
|---|---|---|
| 2026-09-25 | minamiyama | 新規作成（domain層インターフェースとして定義） |

## 概要

[SheetRow](../entities/sheet_row.md)に対する永続化・検索の契約のみを定義する抽象クラス。実装は[SheetRowRepositoryImpl](../../data/repositories/sheet_row_repository_impl.md)が担う。[AddRowUsecase](../usecases/add_row_usecase.md)・[InputCellUsecase](../usecases/input_cell_usecase.md)・[ExportDailySheetToCsvUsecase](../usecases/export_daily_sheet_to_csv_usecase.md)が依存する。`totalAmount`はDBトリガーにより自動更新されるため、更新用メソッドは設けない。

## メソッド一覧

### insert

| 項目 | 内容 |
|---|---|
| シグネチャ | `Future<void> insert(SheetRow row)` |

#### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 行 | row | - | [SheetRow](../entities/sheet_row.md) | 必須 | - |

#### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| - | - | - | void | - |

#### exception

なし

### findById

| 項目 | 内容 |
|---|---|
| シグネチャ | `Future<SheetRow> findById(String rowId)` |

#### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 行ID | rowId | - | string | 必須 | - |

#### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| 行 | - | - | [SheetRow](../entities/sheet_row.md) | - |

#### exception

| exception論理名 | exception物理名 | エラーコード | エラーメッセージ | 備考 |
|---|---|---|---|---|
| レコード未検出 | [RecordNotFoundException](../../../../core/errors/record_not_found_exception.md) | - | - | `entityName="SheetRow"`, `id=rowId` |

### findMaxRowOrder

| 項目 | 内容 |
|---|---|
| シグネチャ | `Future<int> findMaxRowOrder(String sheetInstanceId)` |

#### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 伝票インスタンスID | sheetInstanceId | - | string | 必須 | - |

#### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| 最大表示順 | - | - | int | 該当行なしの場合は0 |

#### exception

なし

### findByInstanceId

| 項目 | 内容 |
|---|---|
| シグネチャ | `Future<List<SheetRow>> findByInstanceId(String sheetInstanceId)` |

#### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 伝票インスタンスID | sheetInstanceId | - | string | 必須 | - |

#### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| 行一覧 | - | list | [SheetRow](../entities/sheet_row.md) | `rowOrder`昇順。該当なしの場合は空リスト |

#### exception

なし
