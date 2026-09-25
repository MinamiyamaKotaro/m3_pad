# HeaderTypeRepository（header_type_repository.dart）

| 新規作成・更新日 | 作成・更新者名 | 作成・更新内容 |
|---|---|---|
| 2026-09-25 | minamiyama | 新規作成（domain層インターフェースとして定義） |

## 概要

[HeaderType](../entities/header_type.md)の検索の契約のみを定義する抽象クラス。実装は[HeaderTypeRepositoryImpl](../../data/repositories/header_type_repository_impl.md)が担う。[AddHeaderUsecase](../usecases/add_header_usecase.md)が依存する。

## メソッド一覧

### findAll

| 項目 | 内容 |
|---|---|
| シグネチャ | `Future<List<HeaderType>> findAll()` |

#### input

なし

#### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| 型一覧 | - | list | [HeaderType](../entities/header_type.md) | 固定5件（int/decimal/string/date/boolean） |

#### exception

なし

### findById

| 項目 | 内容 |
|---|---|
| シグネチャ | `Future<HeaderType> findById(int typeId)` |

#### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 型ID | typeId | - | int | 必須 | - |

#### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| 型 | - | - | [HeaderType](../entities/header_type.md) | - |

#### exception

| exception論理名 | exception物理名 | エラーコード | エラーメッセージ | 備考 |
|---|---|---|---|---|
| レコード未検出 | [RecordNotFoundException](../../../../core/errors/record_not_found_exception.md) | - | - | `entityName="HeaderType"`, `id=typeId.toString()` |
