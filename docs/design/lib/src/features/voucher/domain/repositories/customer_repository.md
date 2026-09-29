# CustomerRepository（customer_repository.dart）

| 新規作成・更新日 | 作成・更新者名 | 作成・更新内容 |
|---|---|---|
| 2026-09-25 | minamiyama | 新規作成（domain層インターフェースとして定義） |
| 2026-09-27 | minamiyama | `insert`を追加（お名前欄への入力による新規顧客の作成に対応、[UpdateRowUsecase](../usecases/update_row_usecase.md)参照）。`findByIds`を追加（[SheetDetail.customersById](../entities/sheet_detail.md)の一括取得用） |
| 2026-09-29 | minamiyama | `findByName`を追加（同名の既存顧客との重複作成を避けるための名前検索、[UpdateRowUsecase](../usecases/update_row_usecase.md)参照） |

## 概要

[Customer](../entities/customer.md)の検索・作成の契約を定義する抽象クラス。実装は[CustomerRepositoryImpl](../../data/repositories/customer_repository_impl.md)が担う。[AddRowUsecase](../usecases/add_row_usecase.md)・[UpdateRowUsecase](../usecases/update_row_usecase.md)・[GetSheetDetailUsecase](../usecases/get_sheet_detail_usecase.md)が依存する。

## メソッド一覧

### insert

| 項目 | 内容 |
|---|---|
| シグネチャ | `Future<void> insert(Customer customer)` |

#### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 顧客 | customer | - | [Customer](../entities/customer.md) | 必須 | 「お名前」列に氏名が入力され、かつその行にまだ`customerId`が紐付いていない場合に、[UpdateRowUsecase](../usecases/update_row_usecase.md)が新規作成する |

#### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| - | - | - | void | - |

#### exception

なし

### findByIds

| 項目 | 内容 |
|---|---|
| シグネチャ | `Future<List<Customer>> findByIds(List<String> customerIds)` |

#### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 顧客IDリスト | customerIds | list | string | 必須, 空リスト許容 | [SheetCellRepository.findByRowIds](./sheet_cell_repository.md)と同様、1件ずつループでDBを呼び出すのではなく一括取得する |

#### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| 顧客一覧 | - | list | [Customer](../entities/customer.md) | 該当なしの場合は空リスト |

#### exception

なし

### findById

| 項目 | 内容 |
|---|---|
| シグネチャ | `Future<Customer> findById(String customerId)` |

#### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 顧客ID | customerId | - | string | 必須 | - |

#### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| 顧客 | - | - | [Customer](../entities/customer.md) | - |

#### exception

| exception論理名 | exception物理名 | エラーコード | エラーメッセージ | 備考 |
|---|---|---|---|---|
| レコード未検出 | [RecordNotFoundException](../../../../core/errors/record_not_found_exception.md) | - | - | `entityName="Customer"`, `id=customerId` |

### findByName

| 項目 | 内容 |
|---|---|
| シグネチャ | `Future<Customer?> findByName(String name)` |

#### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 氏名 | name | - | string | 必須 | 完全一致で検索する |

#### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| 顧客 | - | optional | [Customer](../entities/customer.md) | 該当する有効な顧客が存在しない場合は`null` |

#### exception

なし
