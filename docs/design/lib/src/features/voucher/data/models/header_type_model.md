# HeaderTypeModel（header_type_model.dart）

| 新規作成・更新日 | 作成・更新者名 | 作成・更新内容 |
|---|---|---|
| 2026-09-25 | minamiyama | 新規作成 |

## 概要

[HeaderType](../../domain/entities/header_type.md)のデータ層表現。SQLiteの行（`Map<String, dynamic>`）と相互変換する`fromMap`/`toMap`を持つ。`HeaderTypeModel extends HeaderType`として定義し、フィールド定義はエンティティを継承するため本ドキュメントでは重複記載しない（項目定義は[HeaderType](../../domain/entities/header_type.md)を参照）。[HeaderTypeLocalDataSource](../datasources/header_type_local_datasource.md)・[HeaderTypeRepositoryImpl](../repositories/header_type_repository_impl.md)が使用する。

## 依存関係シーケンス図

```mermaid
classDiagram
    HeaderTypeModel --|> HeaderType : extends
    HeaderTypeLocalDataSource --> HeaderTypeModel : creates
    HeaderTypeRepositoryImpl --> HeaderTypeModel : uses
```

## fromMap

### 処理概要
SQLiteの行（`Map<String, dynamic>`）から`HeaderTypeModel`を生成する。

### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| DB行データ | map | map | string(key), dynamic(value) | 必須 | `m_header_type`テーブルの1行分 |

### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| モデル | - | - | HeaderTypeModel | - |

### exception

なし

### 処理詳細
1. `map['type_id']`→`typeId`、`map['type_name']`→`ColumnValueType`へ変換して`typeName`、`map['created_at']`→DateTimeへ変換して`createdAt`、`map['updated_at']`→DateTimeへ変換して`updatedAt`に対応付け、`HeaderTypeModel`を生成する。
2. 生成したインスタンスを返却する。

## toMap

### 処理概要
`HeaderTypeModel`をSQLiteへ保存可能な`Map<String, dynamic>`に変換する。

### input

なし（自身のフィールドを使用する）

### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| DB行データ | - | map | string(key), dynamic(value) | `typeName`はenum名の文字列、`createdAt`/`updatedAt`はISO8601文字列に変換する |

### exception

なし

### 処理詳細
1. 各フィールドをDBの物理カラム名（snake_case）をキーとした`Map`に変換する。
2. 変換した`Map`を返却する。
