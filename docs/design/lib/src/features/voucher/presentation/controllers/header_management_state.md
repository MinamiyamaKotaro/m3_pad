# HeaderManagementState（header_management_state.dart）

| 新規作成・更新日 | 作成・更新者名 | 作成・更新内容 |
|---|---|---|
| 2026-09-29 | minamiyama | 新規作成（ヘッダー管理機能、FR-6） |

## 概要

ヘッダー管理画面（`MMM_003_VOUCHER`）のUI状態（UiState）を表すクラス。[HeaderManagementNotifier](./header_management_notifier.md)が保持・更新し、[HeaderManagementPage](../pages/header_management_page.md)が監視する。

## 依存関係シーケンス図

```mermaid
classDiagram
    HeaderManagementNotifier --> HeaderManagementState : build/copyWith
    HeaderManagementPage --> HeaderManagementState : watch
    HeaderManagementState --> Header : headers
```

## ライフサイクルに応じた状態遷移

| 状態（論理名/物理名） | 説明 |
|---|---|
| 初期／initial | 画面生成時の状態 |
| 読込中／loading | 列一覧・単価取得中の状態（インジケータ表示用） |
| 成功／success | 取得できた状態。一覧表示・追加/編集操作が可能 |
| エラー／error | 取得に失敗した異常系（エラーメッセージ・再試行ボタン表示用） |

## プロパティ定義

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 画面状態 | status | - | HeaderManagementStatus | 必須 | デフォルト`initial` |
| 価格対象の列一覧 | headers | list | [Header](../../domain/entities/header.md) | 必須 | デフォルト空リスト。「お名前」「MEMO」「合計金額」「担当」を除く（`isPriced=true`のみ）。`displayOrder`昇順 |
| 列ID別の現在の適用単価Map | unitPricesByColumnId | map | string(key), int(value) | 必須 | デフォルト空Map。単価未登録の列はキーを持たない |
| エラーメッセージ | errorMessage | optional | string | `status=error`の場合のみ非`null` | - |
