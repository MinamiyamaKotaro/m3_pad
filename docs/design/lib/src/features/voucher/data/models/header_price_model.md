# HeaderPriceModel（header_price_model.dart）

| 新規作成・更新日 | 作成・更新者名 | 作成・更新内容 |
|---|---|---|
| 2026-09-25 | minamiyama | 新規作成 |

## 概要

[HeaderPrice](../../domain/entities/header_price.md)のデータ層表現。SQLiteの行（`Map<String, dynamic>`）と相互変換する`fromMap`/`toMap`を持つ。`HeaderPriceModel extends HeaderPrice`として定義し、フィールド定義はエンティティを継承するため本ドキュメントでは重複記載しない（項目定義は[HeaderPrice](../../domain/entities/header_price.md)を参照）。[HeaderPriceLocalDataSource](../datasources/header_price_local_datasource.md)・[HeaderPriceRepositoryImpl](../repositories/header_price_repository_impl.md)が使用する。

## 依存関係シーケンス図

```mermaid
classDiagram
    HeaderPriceModel --|> HeaderPrice : extends
    HeaderPriceLocalDataSource --> HeaderPriceModel : creates
    HeaderPriceRepositoryImpl --> HeaderPriceModel : uses
```

## fromMap

### 処理概要
SQLiteの行（`Map<String, dynamic>`）から`HeaderPriceModel`を生成する。

### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| DB行データ | map | map | string(key), dynamic(value) | 必須 | `m_header_price`テーブルの1行分 |

### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| モデル | - | - | HeaderPriceModel | - |

### exception

なし

### 処理詳細
1. `map['price_id']`→`priceId`、`map['column_id']`→`columnId`、`map['price']`→`price`、`map['effective_from']`→DateTimeへ変換して`effectiveFrom`、`map['effective_to']`（`null`許容）→DateTime?へ変換して`effectiveTo`、`map['created_at']`/`map['updated_at']`→DateTimeへ変換してそれぞれ対応付け、`HeaderPriceModel`を生成する。
2. 生成したインスタンスを返却する。

## toMap

### 処理概要
`HeaderPriceModel`をSQLiteへ保存可能な`Map<String, dynamic>`に変換する。

### input

なし（自身のフィールドを使用する）

### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| DB行データ | - | map | string(key), dynamic(value) | `effectiveTo`が`null`の場合はキーの値も`null`。日時はISO8601／日付文字列に変換する |

### exception

なし

### 処理詳細
1. 各フィールドをDBの物理カラム名（snake_case）をキーとした`Map`に変換する。
2. 変換した`Map`を返却する。
