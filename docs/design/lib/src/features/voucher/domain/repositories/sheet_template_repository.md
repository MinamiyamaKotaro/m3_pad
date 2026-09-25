# SheetTemplateRepository（sheet_template_repository.dart）

| 新規作成・更新日 | 作成・更新者名 | 作成・更新内容 |
|---|---|---|
| 2026-09-25 | minamiyama | 新規作成（domain層インターフェースとして定義） |

## 概要

[SheetTemplate](../entities/sheet_template.md)に対する永続化・検索の**契約**のみを定義する抽象クラス（インターフェース）。実装は[SheetTemplateRepositoryImpl](../../data/repositories/sheet_template_repository_impl.md)（data層）が担い、[CreateTemplateUsecase](../usecases/create_template_usecase.md)・[AddHeaderUsecase](../usecases/add_header_usecase.md)・[OpenSheetInstanceUsecase](../usecases/open_sheet_instance_usecase.md)はこのインターフェースにのみ依存する（依存性逆転）。抽象クラスのため処理詳細は持たず、以下ではメソッドのシグネチャ（input/output/exception）のみを定義する。

## メソッド一覧

### insert

| 項目 | 内容 |
|---|---|
| シグネチャ | `Future<void> insert(SheetTemplate template)` |

#### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 伝票フォーマット | template | - | [SheetTemplate](../entities/sheet_template.md) | 必須 | - |

#### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| - | - | - | void | - |

#### exception

なし

### findById

| 項目 | 内容 |
|---|---|
| シグネチャ | `Future<SheetTemplate> findById(String sheetTemplateId)` |

#### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 伝票フォーマットID | sheetTemplateId | - | string | 必須 | - |

#### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| 伝票フォーマット | - | - | [SheetTemplate](../entities/sheet_template.md) | - |

#### exception

| exception論理名 | exception物理名 | エラーコード | エラーメッセージ | 備考 |
|---|---|---|---|---|
| レコード未検出 | [RecordNotFoundException](../../../../core/errors/record_not_found_exception.md) | - | - | `entityName="SheetTemplate"`, `id=sheetTemplateId` |

### findAllActive

| 項目 | 内容 |
|---|---|
| シグネチャ | `Future<List<SheetTemplate>> findAllActive()` |

#### input

なし

#### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| 伝票フォーマット一覧 | - | list | [SheetTemplate](../entities/sheet_template.md) | 該当なしの場合は空リスト |

#### exception

なし
