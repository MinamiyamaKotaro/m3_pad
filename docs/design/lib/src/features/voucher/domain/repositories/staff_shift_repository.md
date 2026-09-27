# StaffShiftRepository（staff_shift_repository.dart）

| 新規作成・更新日 | 作成・更新者名 | 作成・更新内容 |
|---|---|---|
| 2026-09-27 | minamiyama | 新規作成（domain層インターフェースとして定義） |

## 概要

[StaffShift](../entities/staff_shift.md)に対する永続化・検索の契約のみを定義する抽象クラス。実装は[StaffShiftRepositoryImpl](../../data/repositories/staff_shift_repository_impl.md)が担う。[OpenSheetInstanceUsecase](../usecases/open_sheet_instance_usecase.md)・[GetSheetDetailUsecase](../usecases/get_sheet_detail_usecase.md)・[UpdateStaffShiftUsecase](../usecases/update_staff_shift_usecase.md)が依存する。

## メソッド一覧

### insert

| 項目 | 内容 |
|---|---|
| シグネチャ | `Future<void> insert(StaffShift shift)` |

#### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| スタッフシフト | shift | - | [StaffShift](../entities/staff_shift.md) | 必須 | - |

#### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| - | - | - | void | - |

#### exception

なし

### update

| 項目 | 内容 |
|---|---|
| シグネチャ | `Future<void> update(StaffShift shift)` |

#### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| スタッフシフト | shift | - | [StaffShift](../entities/staff_shift.md) | 必須 | `shiftId`で対象を特定し、`staffId`・`startTime`・`endTime`・`drinkBack`を上書きする |

#### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| - | - | - | void | - |

#### exception

| exception論理名 | exception物理名 | エラーコード | エラーメッセージ | 備考 |
|---|---|---|---|---|
| レコード未検出 | [RecordNotFoundException](../../../../core/errors/record_not_found_exception.md) | - | - | `entityName="StaffShift"`, `id=shift.shiftId` |

### findByInstanceId

| 項目 | 内容 |
|---|---|
| シグネチャ | `Future<List<StaffShift>> findByInstanceId(String sheetInstanceId)` |

#### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 伝票インスタンスID | sheetInstanceId | - | string | 必須 | - |

#### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| スタッフシフト一覧 | - | list | [StaffShift](../entities/staff_shift.md) | `createdAt`昇順。該当なしの場合は空リスト |

#### exception

なし
