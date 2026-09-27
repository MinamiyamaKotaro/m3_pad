# SheetRow（sheet_row.dart）

| 新規作成・更新日 | 作成・更新者名 | 作成・更新内容 |
|---|---|---|
| 2026-09-25 | minamiyama | 新規作成 |
| 2026-09-25 | minamiyama | agents.md階層改訂に伴い`domain/entities/`へ移動 |
| 2026-09-27 | minamiyama | `paymentMethod`を追加（[agents.md](../../../../../../../requried/agents.md)の決済方法仕様を反映） |

## 概要

1組の来店・卓（データ行）を表すドメインエンティティ。DBの物理テーブル名は`t_row`だが、Flutter標準の`Row`ウィジェットとの名称衝突を避けるため、Dartクラス名は`SheetRow`とする。[SheetInstance](./sheet_instance.md)配下に複数存在し、任意で[Customer](./customer.md)・[Staff](./staff.md)と紐付く。配下の[SheetCell](./sheet_cell.md)の`amount`合計は`totalAmount`にキャッシュされ、DBトリガーにより自動更新される（FR-2）。DB定義は [db_schema.md](../../../../../../../requried/db_schema.md) §5.8 `t_row` に対応する。

## 依存関係シーケンス図

```mermaid
classDiagram
    SheetInstance "1" --> "0..*" SheetRow : has (sheetInstanceId)
    Customer "1" --> "0..*" SheetRow : visits as (customerId)
    Staff "1" --> "0..*" SheetRow : in charge of (staffId)
    SheetRow "1" --> "0..*" SheetCell : has (rowId)
    SheetRow --> PaymentMethod : paymentMethod
    SheetRow --> RecordStatus : status
```

## 項目一覧

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 行ID | rowId | - | string | 必須, ULID形式 | PK |
| 伝票インスタンスID | sheetInstanceId | - | string | 必須, FK→[SheetInstance](./sheet_instance.md) | どの日の伝票の行か |
| 顧客ID | customerId | optional | string | 任意, FK→[Customer](./customer.md) | 未登録（新規客）の来店は`null`。画面上は「お名前」列に「-様」＋「NEW」マークを表示する |
| スタッフID | staffId | optional | string | 任意, FK→[Staff](./staff.md) | 担当スタッフ（会計を行った人）。行右端の「担当」列で選択する |
| 表示順 | rowOrder | - | int | 必須 | - |
| 合計金額 | totalAmount | - | int | 必須 | デフォルト0。[SheetCell](./sheet_cell.md)の`amount`合計のキャッシュ。DBトリガー(`trg_t_cell_ai/au/ad`)により自動更新されるため、アプリ側から直接書き込まない |
| 決済方法 | paymentMethod | optional | [PaymentMethod](./enums/payment_method.md) | 任意 | 「合計金額」列に隣接する「P」「カ」の丸印に対応。`null`は現金決済（どちらにも丸をつけない） |
| 論理削除状態 | status | - | [RecordStatus](./enums/record_status.md) | 必須 | デフォルト`active` |
| 作成日時 | createdAt | - | DateTime | 必須, ISO8601 | - |
| 更新日時 | updatedAt | - | DateTime | 必須, ISO8601 | - |
