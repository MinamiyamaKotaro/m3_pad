/// ヘッダー（列）のカテゴリーを型安全に扱うための共有enum。
///
/// 伝票入力画面のヘッダーセルの色分け表示（FR-6）に使用する。
enum HeaderCategory {
  /// 未指定。
  none,

  /// ドリンク。
  drink,

  /// ボトル。
  bottle,

  /// フード。
  food;

  /// DB値（`'none'`/`'drink'`/`'bottle'`/`'food'`）から [HeaderCategory] へ
  /// 変換する。
  static HeaderCategory fromDbValue(final String value) =>
      HeaderCategory.values.firstWhere(
        (final HeaderCategory category) => category.dbValue == value,
      );

  /// DB保存用の値（`'none'`/`'drink'`/`'bottle'`/`'food'`）。
  String get dbValue => name;
}
