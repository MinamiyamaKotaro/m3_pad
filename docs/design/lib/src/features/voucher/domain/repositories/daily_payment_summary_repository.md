# DailyPaymentSummaryRepository（daily_payment_summary_repository.dart）

| 新規作成・更新日 | 作成・更新者名 | 作成・更新内容 |
|---|---|---|
| 2026-09-27 | minamiyama | 新規作成（domain層インターフェースとして定義） |

## 概要

[DailyPaymentSummary](../entities/daily_payment_summary.md)の取得の契約のみを定義する抽象クラス。実装は[DailyPaymentSummaryRepositoryImpl](../../data/repositories/daily_payment_summary_repository_impl.md)が担い、DBのビュー`v_daily_payment_summary`（[db_schema.md](../../../../../../../requried/db_schema.md) §6.1）から読み取る。読み取り専用のため更新系メソッドは持たない。[GetSheetDetailUsecase](../usecases/get_sheet_detail_usecase.md)が依存する。

## メソッド一覧

### getByInstanceId

| 項目 | 内容 |
|---|---|
| シグネチャ | `Future<DailyPaymentSummary> getByInstanceId(String sheetInstanceId, DateTime businessDate)` |

#### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 伝票インスタンスID | sheetInstanceId | - | string | 必須 | - |
| 営業日 | businessDate | - | DateTime | 必須, 日付のみ | 該当行が0件だった場合のフォールバック値組み立てに使用する |

#### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| 日次集計 | - | - | [DailyPaymentSummary](../entities/daily_payment_summary.md) | 該当行が1件もない場合は、`businessDate`を用い`totalAmount`・`cashAmount`・`cardAmount`・`paypayAmount`をすべて0とした値を返す（例外は送出しない） |

#### exception

なし
