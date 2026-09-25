# StaffRepository（staff_repository.dart）

| 新規作成・更新日 | 作成・更新者名 | 作成・更新内容 |
|---|---|---|
| 2026-09-25 | minamiyama | 新規作成（domain層インターフェースとして定義） |

## 概要

[Staff](../entities/staff.md)の検索の契約のみを定義する抽象クラス。実装は[StaffRepositoryImpl](../../data/repositories/staff_repository_impl.md)が担う。[AddRowUsecase](../usecases/add_row_usecase.md)が依存する。

## メソッド一覧

### findById

| 項目 | 内容 |
|---|---|
| シグネチャ | `Future<Staff> findById(String staffId)` |

#### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| スタッフID | staffId | - | string | 必須 | - |

#### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| スタッフ | - | - | [Staff](../entities/staff.md) | - |

#### exception

| exception論理名 | exception物理名 | エラーコード | エラーメッセージ | 備考 |
|---|---|---|---|---|
| レコード未検出 | [RecordNotFoundException](../../../../core/errors/record_not_found_exception.md) | - | - | `entityName="Staff"`, `id=staffId` |

### findAllActive

| 項目 | 内容 |
|---|---|
| シグネチャ | `Future<List<Staff>> findAllActive()` |

#### input

なし

#### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| スタッフ一覧 | - | list | [Staff](../entities/staff.md) | 該当なしの場合は空リスト |

#### exception

なし
