# SheetTemplateModel（sheet_template_model.dart）

| 新規作成・更新日 | 作成・更新者名 | 作成・更新内容 |
|---|---|---|
| 2026-09-25 | minamiyama | 新規作成 |

## 概要

[SheetTemplate](../../domain/entities/sheet_template.md)のデータ層表現。SQLiteの行（`Map<String, dynamic>`）と相互変換する`fromMap`/`toMap`を持つ。`SheetTemplateModel extends SheetTemplate`として定義し、フィールド定義はエンティティを継承するため本ドキュメントでは重複記載しない（項目定義は[SheetTemplate](../../domain/entities/sheet_template.md)を参照）。[SheetTemplateLocalDataSource](../datasources/sheet_template_local_datasource.md)がSQLiteから取得した行をこのModelに変換し、[SheetTemplateRepositoryImpl](../repositories/sheet_template_repository_impl.md)がModelを[SheetTemplate](../../domain/entities/sheet_template.md)として上位層へ返却する。

## 依存関係シーケンス図

```mermaid
classDiagram
    SheetTemplateModel --|> SheetTemplate : extends
    SheetTemplateLocalDataSource --> SheetTemplateModel : creates
    SheetTemplateRepositoryImpl --> SheetTemplateModel : uses
```

## fromMap

### 処理概要
SQLiteの行（`Map<String, dynamic>`）から`SheetTemplateModel`を生成する。

### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| DB行データ | map | map | string(key), dynamic(value) | 必須 | `m_sheet_template`テーブルの1行分 |

### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| モデル | - | - | SheetTemplateModel | - |

### exception

なし

### 処理詳細
1. `map['sheet_template_id']`→`sheetTemplateId`、`map['name']`→`name`、`map['status']`→`RecordStatus`へ変換して`status`、`map['created_at']`→DateTimeへ変換して`createdAt`、`map['updated_at']`→DateTimeへ変換して`updatedAt`に対応付け、`SheetTemplateModel`を生成する。
2. 生成したインスタンスを返却する。

## toMap

### 処理概要
`SheetTemplateModel`をSQLiteへ保存可能な`Map<String, dynamic>`に変換する。

### input

なし（自身のフィールドを使用する）

### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| DB行データ | - | map | string(key), dynamic(value) | `status`はenum名の文字列、`createdAt`/`updatedAt`はISO8601文字列に変換する |

### exception

なし

### 処理詳細
1. 各フィールドをDBの物理カラム名（snake_case）をキーとした`Map`に変換する。
2. 変換した`Map`を返却する。
