# HeaderRepository（header_repository.dart）

| 新規作成・更新日 | 作成・更新者名 | 作成・更新内容 |
|---|---|---|
| 2026-09-25 | minamiyama | 新規作成（domain層インターフェースとして定義） |

## 概要

[Header](../entities/header.md)に対する永続化・検索・更新の契約のみを定義する抽象クラス。実装は[HeaderRepositoryImpl](../../data/repositories/header_repository_impl.md)が担う。[AddHeaderUsecase](../usecases/add_header_usecase.md)・[ReorderHeadersUsecase](../usecases/reorder_headers_usecase.md)・[RemoveHeaderUsecase](../usecases/remove_header_usecase.md)・[InputCellUsecase](../usecases/input_cell_usecase.md)・[ExportDailySheetToCsvUsecase](../usecases/export_daily_sheet_to_csv_usecase.md)が依存する。

## メソッド一覧

### insert

| 項目 | 内容 |
|---|---|
| シグネチャ | `Future<void> insert(Header header)` |

#### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 列 | header | - | [Header](../entities/header.md) | 必須 | - |

#### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| - | - | - | void | - |

#### exception

なし

### findById

| 項目 | 内容 |
|---|---|
| シグネチャ | `Future<Header> findById(String columnId)` |

#### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 列ID | columnId | - | string | 必須 | - |

#### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| 列 | - | - | [Header](../entities/header.md) | - |

#### exception

| exception論理名 | exception物理名 | エラーコード | エラーメッセージ | 備考 |
|---|---|---|---|---|
| レコード未検出 | [RecordNotFoundException](../../../../core/errors/record_not_found_exception.md) | - | - | `entityName="Header"`, `id=columnId` |

### findByTemplateId

| 項目 | 内容 |
|---|---|
| シグネチャ | `Future<List<Header>> findByTemplateId(String sheetTemplateId)` |

#### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 伝票フォーマットID | sheetTemplateId | - | string | 必須 | - |

#### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| 列一覧 | - | list | [Header](../entities/header.md) | `displayOrder`昇順。該当なしの場合は空リスト |

#### exception

なし

### updateDisplayOrders

| 項目 | 内容 |
|---|---|
| シグネチャ | `Future<void> updateDisplayOrders(Map<String, int> displayOrderByColumnId)` |

#### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 列IDと表示順の対応 | displayOrderByColumnId | map | string(key), int(value) | 必須, 1件以上 | key=columnId, value=displayOrder。1回のSQLで一括更新される |

#### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| - | - | - | void | - |

#### exception

なし

### updateStatus

| 項目 | 内容 |
|---|---|
| シグネチャ | `Future<void> updateStatus(String columnId, RecordStatus status)` |

#### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 列ID | columnId | - | string | 必須 | - |
| 論理削除状態 | status | - | [RecordStatus](../entities/enums/record_status.md) | 必須 | - |

#### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| - | - | - | void | - |

#### exception

なし
