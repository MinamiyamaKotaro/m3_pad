# SheetInstanceModel（sheet_instance_model.dart）

| 新規作成・更新日 | 作成・更新者名 | 作成・更新内容 |
|---|---|---|
| 2026-09-25 | minamiyama | 新規作成 |

## 概要

[SheetInstance](../../domain/entities/sheet_instance.md)のデータ層表現。SQLiteの行（`Map<String, dynamic>`）と相互変換する`fromMap`/`toMap`を持つ。`SheetInstanceModel extends SheetInstance`として定義し、フィールド定義はエンティティを継承するため本ドキュメントでは重複記載しない（項目定義は[SheetInstance](../../domain/entities/sheet_instance.md)を参照）。[SheetInstanceLocalDataSource](../datasources/sheet_instance_local_datasource.md)・[SheetInstanceRepositoryImpl](../repositories/sheet_instance_repository_impl.md)が使用する。

## 依存関係シーケンス図

```mermaid
classDiagram
    SheetInstanceModel --|> SheetInstance : extends
    SheetInstanceLocalDataSource --> SheetInstanceModel : creates
    SheetInstanceRepositoryImpl --> SheetInstanceModel : uses
```

## fromMap

### 処理概要
SQLiteの行（`Map<String, dynamic>`）から`SheetInstanceModel`を生成する。

### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| DB行データ | map | map | string(key), dynamic(value) | 必須 | `t_sheet_instance`テーブルの1行分 |

### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| モデル | - | - | SheetInstanceModel | - |

### exception

なし

### 処理詳細
1. `map['sheet_instance_id']`→`sheetInstanceId`、`map['sheet_template_id']`→`sheetTemplateId`、`map['business_date']`→DateTimeへ変換して`businessDate`、`map['status']`→`RecordStatus`へ変換して`status`、`map['created_at']`/`map['updated_at']`→DateTimeへ変換してそれぞれ対応付け、`SheetInstanceModel`を生成する。
2. 生成したインスタンスを返却する。

## toMap

### 処理概要
`SheetInstanceModel`をSQLiteへ保存可能な`Map<String, dynamic>`に変換する。

### input

なし（自身のフィールドを使用する）

### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| DB行データ | - | map | string(key), dynamic(value) | `status`はenum名の文字列、日時はISO8601／日付文字列に変換する |

### exception

なし

### 処理詳細
1. 各フィールドをDBの物理カラム名（snake_case）をキーとした`Map`に変換する。
2. 変換した`Map`を返却する。
