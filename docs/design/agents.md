# AGENTS.md (design-rules)

## 1. ドキュメントの階層について
* design配下は以下の階層とする(flutterの階層と同じにする)
```
lib/
├── main.dart                  # アプリの起動エントリーポイント
└── src/
    ├── app.dart               # MaterialAppの設定やルート定義
    ├── core/                  # アプリ全体で共有する共通基盤
    │   ├── errors/            # 例外・エラーハンドリング
    │   ├── network/           # HTTPクライアント共通設定
    │   ├── theme/             # 共通のデザインシステム・テーマ
    │   └── utils/             # 拡張関数やヘルパー
    │
    └── features/              # 機能ごとのディレクトリ
        └── voucher/              # 「伝票機能」
            ├── domain/        # ① ドメイン層（ビジネスロジックの中心・純粋なDart）
            │   ├── entities/  # 画面やデータ源に依存しない純粋なデータモデル
            │   ├── repositories/# リポジトリの「インターフェース（抽象クラス）」
            │   └── usecases/  # ユーザーの行動（ユースケース）ごとのロジック
            │
            ├── data/          # ② データ層（外部連携の実装）
            │   ├── datasources/ # API通信（Remote）やローカルDB（Local）の直接の処理
            │   ├── models/    # JSON変換（fromJson/toJson）などを持つデータモデル
            │   └── repositories/# ドメイン層で定義したリポジトリの実装クラス（Implements）
            │
            └── presentation/  # ③ プレゼンテーション層（UIと状態管理）
                ├── controllers/ # RiverpodのNotifierやBLoCなど（状態管理）
                ├── pages/     # 画面全体のウィジェット
                └── widgets/   # その機能内だけで使う小さなUIパーツ
```

## 2. ドキュメントの内容について
* **使用言語** 日本語
* **作成・更新者** minamiyama
* ドキュメントのヘッダーについて
  - 以下ヘッダー部に必ず記載すること
    - 機能名( **英語** のソース名)
    - 表形式で新規作成・更新日と作成更新者名・作成更新内容
* 1ソースに対して1ドキュメントとする。
* ドキュメントについては以下の内容を記載すること
* service・controllerの記載について
  - 処理概要：全体の処理の内容を記載する
  - 処理シーケンス図 ： メソッドごとの呼び出しを記載する
  - メソッド名
    - 処理概要
    - input/output/exception
      - input項目 ： 表形式で記載する
        - 項目論理名
        - 項目物理名
        - カプセルの型 (optional list map等　存在しない場合は半角ハイフンとする)
        - データ型 (string int float)　
        - バリデーション
        - 備考欄(値例やenumの内容について)
      - output項目： 表形式で記載する
        - 項目論理名
        - 項目物理名
        - カプセルの型 (optional list map等　存在しない場合は半角ハイフンとする)
        - データ型 (string int float)　
        - 備考欄(値例やenumの内容について)
      - exception項目 : 表形式で記載する
        - exception論理名
        - exception物理名
        - エラーコード
        - エラーメッセージ
        - 備考欄(発生条件のリンク等)
    - 処理詳細
      - 1から始まる数字 (1)から始まる数字 iから始まる小文字のローマ数字の階層で記載する
        ```example
         1. businessDateをデータ型を確認する
          　(1). `businessDate`が`YYYY-MM-DD`形式であることを検証する。
                i. testtesttest
        ```
      - 条件分岐の場合は 条件(aから始まる小文字ローマ字)で記載する
        ```example
         条件a: 該当する伝票が存在しない場合、`SheetInstanceNotFoundException`を送出し処理を終了する。
         条件b: 存在する場合、変数`sheetInstance`に格納し次のステップへ進む。
        ```
      - ネストの最大値は３とする
      - 繰り返し内でDBの呼び出しを禁止とする
      - 変数が必要な場合の処理行ごとに表形式で記載を行う
        - 変数論理名
        - 変数物理名
        - データ型
        - 格納値
        - 備考欄(値例やenumの内容について)
      - SQLの取得更新削除が必要な場合、
        - SQL呼び出し先のリポジトリのメソッド名(リンクをつける)
        - 取得結果がある場合、
          - 変数論理名
          - 変数物理名 (複数の場合は複数形、単数の場合は単数系で分ける)
          - カプセルの型名 (optional list map等)
          - データ型名 (string int float)　
* model・dto・entityの記載について
  - 概要：使用箇所について記載する
  - 依存関係シーケンス図：クラスとの依存関係を記載する
  - 以下の内容を**表形式**で記載する
    - 項目論理名
    - 項目物理名
    - カプセルの型名 (optional list map等　存在しない場合は半角ハイフンとする)
    - データ型名 (string int float)　
    - バリデーション
    - 備考欄(値例やenumの内容について)

* presentationについて
  - 画面ID : MMM_{001-999}_VOUCHERと表記する
  -  設計書の記載について
    - UI状態（UiState）のプロパティ
      - 画面に表示するデータ
      - フィルタリングやソートの状態
      - テキスト入力欄の現在値
    - ライフサイクルに応じた状態遷移
      - 初期（Initial）: 画面生成時の状態
      - 読込中（Loading）: APIなどからデータ取得中の状態（インジケータ表示用）
      - 成功（Success / Data）: データが正常に取得でき、画面描画が可能な状態
      - エラー（Error）: 通信失敗などの異常系（エラーメッセージ、再試行ボタン表示用）
      - 空（Empty）: 取得結果が0件だった場合の専用UI用
    - プロパティ定義
      - 以下の内容を**表形式**で記載する
        - 項目論理名
        - 項目物理名
        - カプセルの型名 (optional list map等　存在しない場合は半角ハイフンとする)
        - データ型名 (string int float)　
        - バリデーション
        - 備考欄(値例やenumの内容について)
    - 状態遷移仕様（イベントマトリクスで記載する）
      - 現在の状態(論理名/物理名)
      - 契機（イベント/操作）
      - 遷移後の状態(論理名/物理名)
      - 処理内容・更新されるプロパティ
    - 副作用（Side Effect）仕様
      - 状態（State）としては保持せず、コントローラーからUIへ通知する1回限りのイベントを記載
        - 処理成功時、失敗時で記載する
    - UI（Widget）構造・コンポーネント分割設計について
      - 画面（Page / Screen）ウィジェット
        - 画面全体の土台（Scaffold）を配置し、状態（State）を監視（watch / listen）する責務を持つ。
        - 状態（Loading/Success/Error）に応じて表示する子ウィジェットを切り替える。
      - 子コンポーネント（Widgets）の分割定義
        - 画面内でのみ使う小さなパーツをリストアップ。
      - 共通UIコンポーネントの利用
        - src/core/theme/ や src/core/widgets/ にある共通ボタンやローディング表示の適用指定。


* dartのドキュメント記載方法については、以下を参照する
  - [skills.md](./skills/dart/dart-write-documentation/skills.md)
* flutterのドキュメント記載方法については、以下を参照する
  - [skills.md](./skills/flutter/flutter-apply-architecture-best-practices/skills.md)

## 3. 品質について
* big-oの計算量がn(o^2)にならないように設計する
* 依存度が低い依存度(疎結合)になるように設計する
* 冗長な設計を避ける
* SQLの取得結果は、必ずカプセルに格納して返却する
