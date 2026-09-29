# SheetInstanceRepository（sheet_instance_repository.dart）

| 新規作成・更新日 | 作成・更新者名 | 作成・更新内容 |
|---|---|---|
| 2026-09-25 | minamiyama | 新規作成（domain層インターフェースとして定義） |
| 2026-09-29 | minamiyama | `findByTemplateIdAndDateRange`を追加（CSV期間出力、[ExportSheetsToCsvByDateRangeUsecase](../usecases/export_sheets_to_csv_by_date_range_usecase.md)参照、FR-3） |

## 概要

[SheetInstance](../entities/sheet_instance.md)に対する永続化・検索の契約のみを定義する抽象クラス。実装は[SheetInstanceRepositoryImpl](../../data/repositories/sheet_instance_repository_impl.md)が担う。[OpenSheetInstanceUsecase](../usecases/open_sheet_instance_usecase.md)・[InputCellUsecase](../usecases/input_cell_usecase.md)・[ExportDailySheetToCsvUsecase](../usecases/export_daily_sheet_to_csv_usecase.md)・[ExportSheetsToCsvByDateRangeUsecase](../usecases/export_sheets_to_csv_by_date_range_usecase.md)が依存する。

## メソッド一覧

### insert

| 項目 | 内容 |
|---|---|
| シグネチャ | `Future<void> insert(SheetInstance instance)` |

#### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 伝票インスタンス | instance | - | [SheetInstance](../entities/sheet_instance.md) | 必須 | - |

#### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| - | - | - | void | - |

#### exception

なし

### findById

| 項目 | 内容 |
|---|---|
| シグネチャ | `Future<SheetInstance> findById(String sheetInstanceId)` |

#### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 伝票インスタンスID | sheetInstanceId | - | string | 必須 | - |

#### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| 伝票インスタンス | - | - | [SheetInstance](../entities/sheet_instance.md) | - |

#### exception

| exception論理名 | exception物理名 | エラーコード | エラーメッセージ | 備考 |
|---|---|---|---|---|
| レコード未検出 | [RecordNotFoundException](../../../../core/errors/record_not_found_exception.md) | - | - | `entityName="SheetInstance"`, `id=sheetInstanceId` |

### findByTemplateAndDate

| 項目 | 内容 |
|---|---|
| シグネチャ | `Future<SheetInstance?> findByTemplateAndDate(String sheetTemplateId, DateTime businessDate)` |

#### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 伝票フォーマットID | sheetTemplateId | - | string | 必須 | - |
| 営業日 | businessDate | - | DateTime | 必須, 日付のみ | - |

#### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| 伝票インスタンス | - | optional | [SheetInstance](../entities/sheet_instance.md) | 未作成の場合は`null` |

#### exception

なし

### findByTemplateIdAndDateRange

| 項目 | 内容 |
|---|---|
| シグネチャ | `Future<List<SheetInstance>> findByTemplateIdAndDateRange(String sheetTemplateId, DateTime from, DateTime to)` |

#### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 伝票フォーマットID | sheetTemplateId | - | string | 必須 | - |
| 開始日 | from | - | DateTime | 必須, 日付のみ | 範囲の両端を含む |
| 終了日 | to | - | DateTime | 必須, 日付のみ | 範囲の両端を含む |

#### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| 伝票インスタンス一覧 | - | list | [SheetInstance](../entities/sheet_instance.md) | `businessDate`昇順。該当なしの場合は空リスト |

#### exception

なし
