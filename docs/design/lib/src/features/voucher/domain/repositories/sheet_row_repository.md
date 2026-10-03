# SheetRowRepository（sheet_row_repository.dart）

| 新規作成・更新日 | 作成・更新者名 | 作成・更新内容 |
|---|---|---|
| 2026-09-25 | minamiyama | 新規作成（domain層インターフェースとして定義） |
| 2026-09-27 | minamiyama | `update`を追加（お名前・担当・決済方法の後からの変更に対応、[UpdateRowUsecase](../usecases/update_row_usecase.md)参照） |
| 2026-09-29 | minamiyama | `findByInstanceIds`を追加（複数営業日分の一括取得、[ExportSheetsToCsvByDateRangeUsecase](../usecases/export_sheets_to_csv_by_date_range_usecase.md)参照、FR-3） |
| 2026-10-03 | minamiyama | お名前の登録後も初来店の伝票で「NEW」マークを表示するため、`findCustomerIdsVisitedBefore`を追加（[GetSheetDetailUsecase](../usecases/get_sheet_detail_usecase.md)参照） |

## 概要

[SheetRow](../entities/sheet_row.md)に対する永続化・検索の契約のみを定義する抽象クラス。実装は[SheetRowRepositoryImpl](../../data/repositories/sheet_row_repository_impl.md)が担う。[AddRowUsecase](../usecases/add_row_usecase.md)・[InputCellUsecase](../usecases/input_cell_usecase.md)・[UpdateRowUsecase](../usecases/update_row_usecase.md)・[ExportDailySheetToCsvUsecase](../usecases/export_daily_sheet_to_csv_usecase.md)・[ExportSheetsToCsvByDateRangeUsecase](../usecases/export_sheets_to_csv_by_date_range_usecase.md)が依存する。`totalAmount`はDBトリガーにより自動更新されるため、`update`の対象には含めない。

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

### update

| 項目 | 内容 |
|---|---|
| シグネチャ | `Future<void> update(SheetRow row)` |

#### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 行 | row | - | [SheetRow](../entities/sheet_row.md) | 必須 | `rowId`で対象を特定し、`customerId`・`staffId`・`paymentMethod`を上書きする。`totalAmount`はDBトリガーで管理するため本メソッドでは更新しない |

#### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| - | - | - | void | - |

#### exception

| exception論理名 | exception物理名 | エラーコード | エラーメッセージ | 備考 |
|---|---|---|---|---|
| レコード未検出 | [RecordNotFoundException](../../../../core/errors/record_not_found_exception.md) | - | - | `entityName="SheetRow"`, `id=row.rowId` |

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

### findByInstanceIds

| 項目 | 内容 |
|---|---|
| シグネチャ | `Future<List<SheetRow>> findByInstanceIds(List<String> sheetInstanceIds)` |

#### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 伝票インスタンスID一覧 | sheetInstanceIds | list | string | 必須 | 複数営業日分を1回のクエリで取得する（CSV期間出力での繰り返しDB呼び出し回避） |

#### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| 行一覧 | - | list | [SheetRow](../entities/sheet_row.md) | `sheetInstanceId`・`rowOrder`昇順。該当なしの場合は空リスト |

#### exception

なし

### findCustomerIdsVisitedBefore

| 項目 | 内容 |
|---|---|
| シグネチャ | `Future<List<String>> findCustomerIdsVisitedBefore(List<String> customerIds, DateTime businessDate)` |

#### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 顧客ID一覧 | customerIds | list | string | 必須 | 空の場合は空リストを返す |
| 営業日 | businessDate | - | DateTime | 必須, 日付のみ | この日より前（当日を含まない）の来店履歴を検索する |

#### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| 来店履歴がある顧客ID一覧 | - | list | string | 重複なし。含まれない顧客は`businessDate`が初来店の新規客 |

#### exception

なし
