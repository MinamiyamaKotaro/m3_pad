# SheetInstanceRepository（sheet_instance_repository.dart）

| 新規作成・更新日 | 作成・更新者名 | 作成・更新内容 |
|---|---|---|
| 2026-09-25 | minamiyama | 新規作成（domain層インターフェースとして定義） |

## 概要

[SheetInstance](../entities/sheet_instance.md)に対する永続化・検索の契約のみを定義する抽象クラス。実装は[SheetInstanceRepositoryImpl](../../data/repositories/sheet_instance_repository_impl.md)が担う。[OpenSheetInstanceUsecase](../usecases/open_sheet_instance_usecase.md)・[InputCellUsecase](../usecases/input_cell_usecase.md)・[ExportDailySheetToCsvUsecase](../usecases/export_daily_sheet_to_csv_usecase.md)が依存する。

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
