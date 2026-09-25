# HeaderPriceRepository（header_price_repository.dart）

| 新規作成・更新日 | 作成・更新者名 | 作成・更新内容 |
|---|---|---|
| 2026-09-25 | minamiyama | 新規作成（domain層インターフェースとして定義） |

## 概要

[HeaderPrice](../entities/header_price.md)に対する永続化・検索・更新の契約のみを定義する抽象クラス。実装は[HeaderPriceRepositoryImpl](../../data/repositories/header_price_repository_impl.md)が担う。[AddHeaderUsecase](../usecases/add_header_usecase.md)・[UpdateHeaderPriceUsecase](../usecases/update_header_price_usecase.md)・[InputCellUsecase](../usecases/input_cell_usecase.md)が依存する。

## メソッド一覧

### insert

| 項目 | 内容 |
|---|---|
| シグネチャ | `Future<void> insert(HeaderPrice headerPrice)` |

#### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 単価改定履歴 | headerPrice | - | [HeaderPrice](../entities/header_price.md) | 必須 | - |

#### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| - | - | - | void | - |

#### exception

なし

### findCurrentPrice

| 項目 | 内容 |
|---|---|
| シグネチャ | `Future<HeaderPrice> findCurrentPrice(String columnId, DateTime targetDate)` |

#### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 列ID | columnId | - | string | 必須 | - |
| 対象日 | targetDate | - | DateTime | 必須, 日付のみ | - |

#### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| 単価改定履歴 | - | - | [HeaderPrice](../entities/header_price.md) | 対象日時点で有効な1件 |

#### exception

| exception論理名 | exception物理名 | エラーコード | エラーメッセージ | 備考 |
|---|---|---|---|---|
| レコード未検出 | [RecordNotFoundException](../../../../core/errors/record_not_found_exception.md) | - | - | `entityName="HeaderPrice"`, `id=columnId`。対象日時点で有効な単価が1件も登録されていない場合 |

### closeCurrentPrice

| 項目 | 内容 |
|---|---|
| シグネチャ | `Future<void> closeCurrentPrice(String priceId, DateTime effectiveTo)` |

#### input

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | バリデーション | 備考 |
|---|---|---|---|---|---|
| 価格ID | priceId | - | string | 必須 | - |
| 適用終了日 | effectiveTo | - | DateTime | 必須, 日付のみ | - |

#### output

| 項目論理名 | 項目物理名 | カプセルの型 | データ型 | 備考 |
|---|---|---|---|---|
| - | - | - | void | - |

#### exception

なし
