/// 伝票の列（ヘッダー）に入力できる値の型（DB上の`m_header_type.type_name`
/// カラム）をアプリ層で型安全に扱うためのenum。
///
/// `int`はDartの予約型と衝突するため、enum値名は[integer]とする。
enum ColumnValueType {
  /// 整数値の列（数量など）。
  integer,

  /// 小数値の列（単価計算等）。
  decimal,

  /// 文字列の列（氏名・備考等）。
  string,

  /// 日付値の列。
  date,

  /// 真偽値の列（チェックボックス等）。
  boolean;

  /// DB値から [ColumnValueType] へ変換する。`int`は[integer]に対応する。
  static ColumnValueType fromDbValue(final String value) =>
      ColumnValueType.values.firstWhere(
        (final ColumnValueType type) => type.dbValue == value,
      );

  /// DB保存用の値。[integer]は`'int'`に対応する。
  String get dbValue => this == ColumnValueType.integer ? 'int' : name;
}
