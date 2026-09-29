/// 金額を3桁区切りカンマ付きの「¥」表示文字列に変換するユーティリティ
/// 関数群。
library;

/// [amount] を`¥1,234`のような3桁区切りカンマ付きの文字列に変換する。
String formatYen(final int amount) => '¥${_withThousandsSeparator(amount)}';

/// [value] の整数部分を3桁区切りカンマ付きの文字列に変換する。
String _withThousandsSeparator(final int value) {
  final bool isNegative = value < 0;
  final String digits = value.abs().toString();
  final StringBuffer buffer = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    final int remaining = digits.length - i;
    if (i > 0 && remaining % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(digits[i]);
  }
  return isNegative ? '-$buffer' : buffer.toString();
}
