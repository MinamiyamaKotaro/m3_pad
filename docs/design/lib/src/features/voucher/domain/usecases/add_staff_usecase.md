# AddStaffUsecase（add_staff_usecase.dart）

| 新規作成・更新日 | 作成・更新者名 | 作成・更新内容 |
|---|---|---|
| 2026-09-29 | minamiyama | 新規作成（スタッフ管理機能、FR-7） |

## 処理概要

スタッフを1件追加するユースケース（FR-7）。[StaffRepository](../repositories/staff_repository.md)・[IdGenerator](../../../../core/utils/id_generator.md)に依存する。

## 処理シーケンス図

```mermaid
sequenceDiagram
    participant C as Caller
    participant U as AddStaffUsecase
    participant SR as StaffRepository
    participant G as IdGenerator

    C->>U: call(name)
    U->>G: generate()
    U->>SR: insert(staff)
```

## call

### 処理概要
指定した氏名でスタッフを追加する。

### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 氏名 | name | - | string | 必須, 空文字列・空白のみ不可 | - |

### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| スタッフ | - | - | [Staff](../entities/staff.md) | - |

### exception

| exception論理名 | exception物理名 | エラーコード | エラーメッセージ | 備考 |
|---|---|---|---|---|
| 業務ルール違反 | [ValidationException](../../../../core/errors/validation_exception.md) | - | - | `name`が空文字列・空白のみの場合 |

### 処理詳細
1. 条件a: `name`が空文字列または空白のみの場合、`ValidationException`を送出し処理を終了する。\
   条件b: それ以外の場合、次のステップへ進む。
2. [IdGenerator.generate](../../../../core/utils/id_generator.md)を呼び出し、変数`staffId`に格納する。
3. `staffId`・`name`・`status=active`から[Staff](../entities/staff.md)エンティティを組み立て、変数`staff`に格納する。
4. [StaffRepository.insert](../repositories/staff_repository.md)を`staff`で呼び出し、永続化する。
5. `staff`を返却する。

### 変数一覧

| 変数論理名 | 変数物理名 | データ型 | 格納値 | 備考欄 |
|---|---|---|---|---|
| スタッフID | staffId | string | [IdGenerator.generate](../../../../core/utils/id_generator.md)の返却値 | ULID形式 |
| スタッフ | staff | [Staff](../entities/staff.md) | ステップ3で組み立てたエンティティ | - |
