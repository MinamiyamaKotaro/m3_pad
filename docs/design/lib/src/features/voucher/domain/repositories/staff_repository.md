# StaffRepository（staff_repository.dart）

| 新規作成・更新日 | 作成・更新者名 | 作成・更新内容 |
|---|---|---|
| 2026-09-25 | minamiyama | 新規作成（domain層インターフェースとして定義） |
| 2026-09-29 | minamiyama | `insert`・`updateName`・`updateStatus`を追加（スタッフ管理機能、FR-7） |
| 2026-09-29 | minamiyama | `findByName`を追加（過去に論理削除した同名スタッフの復元用、[AddStaffUsecase](../usecases/add_staff_usecase.md)参照） |

## 概要

[Staff](../entities/staff.md)に対する永続化・検索・更新の契約を定義する抽象クラス。実装は[StaffRepositoryImpl](../../data/repositories/staff_repository_impl.md)が担う。[AddRowUsecase](../usecases/add_row_usecase.md)・[AddStaffUsecase](../usecases/add_staff_usecase.md)・[UpdateStaffUsecase](../usecases/update_staff_usecase.md)・[RemoveStaffUsecase](../usecases/remove_staff_usecase.md)が依存する。

## メソッド一覧

### insert

| 項目 | 内容 |
|---|---|
| シグネチャ | `Future<void> insert(Staff staff)` |

#### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| スタッフ | staff | - | [Staff](../entities/staff.md) | 必須 | - |

#### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| - | - | - | void | - |

#### exception

なし

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

### findByName

| 項目 | 内容 |
|---|---|
| シグネチャ | `Future<Staff?> findByName(String name)` |

#### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 氏名 | name | - | string | 必須 | 完全一致で検索する |

#### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| スタッフ | - | optional | [Staff](../entities/staff.md) | 論理削除済みも含めて検索する（同名の論理削除済みスタッフを復元するため）。該当なしの場合は`null` |

#### exception

なし

### updateName

| 項目 | 内容 |
|---|---|
| シグネチャ | `Future<void> updateName(String staffId, String name)` |

#### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| スタッフID | staffId | - | string | 必須 | - |
| 氏名 | name | - | string | 必須 | - |

#### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| - | - | - | void | - |

#### exception

| exception論理名 | exception物理名 | エラーコード | エラーメッセージ | 備考 |
|---|---|---|---|---|
| レコード未検出 | [RecordNotFoundException](../../../../core/errors/record_not_found_exception.md) | - | - | `entityName="Staff"`, `id=staffId` |

### updateStatus

| 項目 | 内容 |
|---|---|
| シグネチャ | `Future<void> updateStatus(String staffId, RecordStatus status)` |

#### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| スタッフID | staffId | - | string | 必須 | - |
| 論理削除状態 | status | - | [RecordStatus](../entities/enums/record_status.md) | 必須 | - |

#### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| - | - | - | void | - |

#### exception

なし
