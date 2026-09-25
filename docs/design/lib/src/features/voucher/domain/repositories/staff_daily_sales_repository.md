# StaffDailySalesRepository（staff_daily_sales_repository.dart）

| 新規作成・更新日 | 作成・更新者名 | 作成・更新内容 |
|---|---|---|
| 2026-09-25 | minamiyama | 新規作成（domain層インターフェースとして定義） |

## 概要

ビュー`v_staff_daily_sales`（[db_schema.md](../../../../../../../requried/db_schema.md) §6）を参照し、[StaffDailySales](../entities/staff_daily_sales.md)を取得する契約のみを定義する抽象クラス。テーブルではなくビューを参照する読み取り専用の性質のため、永続化系メソッドは持たない。実装は[StaffDailySalesRepositoryImpl](../../data/repositories/staff_daily_sales_repository_impl.md)が担う。[GetDailySalesUsecase](../usecases/get_daily_sales_usecase.md)（FR-4）・[ExportStaffDailySalesToCsvUsecase](../usecases/export_staff_daily_sales_to_csv_usecase.md)（FR-3）が依存する。

## メソッド一覧

### findByDateRange

| 項目 | 内容 |
|---|---|
| シグネチャ | `Future<List<StaffDailySales>> findByDateRange(DateTime dateFrom, DateTime dateTo, {String? staffId})` |

#### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 営業日(開始) | dateFrom | - | DateTime | 必須, 日付のみ | - |
| 営業日(終了) | dateTo | - | DateTime | 必須, 日付のみ, `dateFrom`以降 | - |
| スタッフID | staffId | optional | string | 任意 | 指定時は該当スタッフのみに絞り込む |

#### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| スタッフ別日別売上一覧 | - | list | [StaffDailySales](../entities/staff_daily_sales.md) | 該当なしの場合は空リスト |

#### exception

なし
