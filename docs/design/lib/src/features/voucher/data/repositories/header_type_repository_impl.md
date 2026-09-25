# HeaderTypeRepositoryImpl（header_type_repository_impl.dart）

| 新規作成・更新日 | 作成・更新者名 | 作成・更新内容 |
|---|---|---|
| 2026-09-25 | minamiyama | 新規作成 |

## 処理概要

[HeaderTypeRepository](../../domain/repositories/header_type_repository.md)（domain層インターフェース）の実装クラス。[HeaderTypeLocalDataSource](../datasources/header_type_local_datasource.md)へ処理を委譲する。[HeaderTypeModel](../models/header_type_model.md)は[HeaderType](../../domain/entities/header_type.md)のサブクラスのため、返却値をそのままdomain層の戻り値として返却できる。

## 処理シーケンス図

```mermaid
sequenceDiagram
    participant U as Usecase
    participant Impl as HeaderTypeRepositoryImpl
    participant D as HeaderTypeLocalDataSource

    U->>Impl: findAll()
    Impl->>D: findAll()
    U->>Impl: findById(typeId)
    Impl->>D: findById(typeId)
```

## findAll

### 処理概要
[HeaderTypeLocalDataSource.findAll](../datasources/header_type_local_datasource.md)に処理を委譲する。

### input

なし

### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| 型一覧 | - | list | [HeaderType](../../domain/entities/header_type.md) | 実体は[HeaderTypeModel](../models/header_type_model.md)のリスト |

### exception

なし

### 処理詳細
1. [HeaderTypeLocalDataSource.findAll](../datasources/header_type_local_datasource.md)を呼び出し、結果をそのまま返却する。

## findById

### 処理概要
[HeaderTypeLocalDataSource.findById](../datasources/header_type_local_datasource.md)に処理を委譲する。

### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 型ID | typeId | - | int | 必須 | - |

### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| 型 | - | - | [HeaderType](../../domain/entities/header_type.md) | 実体は[HeaderTypeModel](../models/header_type_model.md) |

### exception

| exception論理名 | exception物理名 | エラーコード | エラーメッセージ | 備考 |
|---|---|---|---|---|
| レコード未検出 | [RecordNotFoundException](../../../../core/errors/record_not_found_exception.md) | - | - | [HeaderTypeLocalDataSource.findById](../datasources/header_type_local_datasource.md)からそのまま伝播 |

### 処理詳細
1. [HeaderTypeLocalDataSource.findById](../datasources/header_type_local_datasource.md)を呼び出し、結果をそのまま返却する。
