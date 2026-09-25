# SheetInstanceLocalDataSource（sheet_instance_local_datasource.dart）

| 新規作成・更新日 | 作成・更新者名 | 作成・更新内容 |
|---|---|---|
| 2026-09-25 | minamiyama | 新規作成 |

## 処理概要

`t_sheet_instance`テーブルに対する実際のSQL実行を担うローカルデータソース。[SheetInstanceRepositoryImpl](../repositories/sheet_instance_repository_impl.md)から呼び出され、[SheetInstanceModel](../models/sheet_instance_model.md)を介してSQLiteの行とやり取りする。

## 処理シーケンス図

```mermaid
sequenceDiagram
    participant R as SheetInstanceRepositoryImpl
    participant D as SheetInstanceLocalDataSource
    participant DB as SQLite

    R->>D: insert(model)
    D->>DB: INSERT INTO t_sheet_instance ...
    R->>D: findById(sheetInstanceId)
    D->>DB: SELECT * FROM t_sheet_instance WHERE sheet_instance_id = ?
    R->>D: findByTemplateAndDate(sheetTemplateId, businessDate)
    D->>DB: SELECT * FROM t_sheet_instance WHERE sheet_template_id = ? AND business_date = ?
```

## insert

### 処理概要
新しい[SheetInstanceModel](../models/sheet_instance_model.md)を1件永続化する。

### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 伝票インスタンス | model | - | [SheetInstanceModel](../models/sheet_instance_model.md) | 必須 | - |

### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| - | - | - | void | - |

### exception

なし

### 処理詳細
1. `model.toMap`で変換した`Map`を値としたINSERT文をDBに対して1回発行する。
   ```sql
   INSERT INTO t_sheet_instance (sheet_instance_id, sheet_template_id, business_date, status, created_at, updated_at)
   VALUES (:sheetInstanceId, :sheetTemplateId, :businessDate, :status, :createdAt, :updatedAt);
   ```

## findById

### 処理概要
`sheetInstanceId`に一致する有効な[SheetInstanceModel](../models/sheet_instance_model.md)を1件取得する。

### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 伝票インスタンスID | sheetInstanceId | - | string | 必須 | - |

### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| 伝票インスタンス | - | - | [SheetInstanceModel](../models/sheet_instance_model.md) | - |

### exception

| exception論理名 | exception物理名 | エラーコード | エラーメッセージ | 備考 |
|---|---|---|---|---|
| レコード未検出 | [RecordNotFoundException](../../../../core/errors/record_not_found_exception.md) | - | - | `entityName="SheetInstance"`, `id=sheetInstanceId` |

### 処理詳細
1. 以下のSQLをDBに対して1回発行する。
   ```sql
   SELECT * FROM t_sheet_instance WHERE sheet_instance_id = :sheetInstanceId AND status = 'active';
   ```
   条件a: 取得結果が0件の場合、`RecordNotFoundException`を送出し処理を終了する。\
   条件b: 取得結果が1件の場合、次のステップへ進む。
2. 取得した1件を[SheetInstanceModel.fromMap](../models/sheet_instance_model.md)で変換して返却する。

## findByTemplateAndDate

### 処理概要
`sheetTemplateId`と`businessDate`の組に一致する有効な[SheetInstanceModel](../models/sheet_instance_model.md)を取得する。当日分がまだ作成されていないケースを許容するため、未検出時は例外ではなく`null`を返す。

### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 伝票フォーマットID | sheetTemplateId | - | string | 必須 | - |
| 営業日 | businessDate | - | DateTime | 必須, 日付のみ | - |

### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| 伝票インスタンス | - | optional | [SheetInstanceModel](../models/sheet_instance_model.md) | 未作成の場合は`null` |

### exception

なし

### 処理詳細
1. 以下のSQLをDBに対して1回発行する。
   ```sql
   SELECT * FROM t_sheet_instance
   WHERE sheet_template_id = :sheetTemplateId AND business_date = :businessDate AND status = 'active';
   ```
   条件a: 取得結果が0件の場合、`null`を返却し処理を終了する。\
   条件b: 取得結果が1件の場合、次のステップへ進む。
2. 取得した1件を[SheetInstanceModel.fromMap](../models/sheet_instance_model.md)で変換して返却する。
