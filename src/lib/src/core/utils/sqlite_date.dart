/// SQLiteの日付のみ（`YYYY-MM-DD`）カラムと[DateTime]を相互変換する
/// ユーティリティ関数群。
library;

/// [date] を`YYYY-MM-DD`形式の文字列に変換する。
String formatDateOnly(final DateTime date) =>
    date.toIso8601String().substring(0, 10);

/// `YYYY-MM-DD`形式の [value] から[DateTime]を生成する。
DateTime parseDateOnly(final String value) => DateTime.parse(value);
