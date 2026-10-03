/// 就業時刻などの時刻を`HH:mm`形式の文字列で扱うユーティリティ関数群。
library;

/// [dateTime] の時・分を`HH:mm`形式（24時間表記・ゼロ埋め）の文字列に変換
/// する。
String formatHHmm(final DateTime dateTime) =>
    '${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}';

/// 入力された時刻文字列 [input] を`HH:mm`形式に正規化する。
///
/// 前後の空白を除去し、全角の数字・コロンは半角に変換したうえで、
/// `H:mm`・`HH:mm`・コロンなしの`Hmm`・`HHmm`を受け付ける。時が0〜23、
/// 分が0〜59の範囲外、またはいずれの形式にも一致しない場合は`null`を返す
/// （例: `9:05`→`09:05`、`１８：３０`→`18:30`、`2400`→`null`）。
String? normalizeHHmm(final String input) {
  final String halfWidth = _toHalfWidth(input.trim());
  final RegExpMatch? match =
      RegExp(r'^(\d{1,2}):?(\d{2})$').firstMatch(halfWidth);
  if (match == null) {
    return null;
  }
  final int hour = int.parse(match.group(1)!);
  final int minute = int.parse(match.group(2)!);
  if (hour > 23 || minute > 59) {
    return null;
  }
  return '${_twoDigits(hour)}:${_twoDigits(minute)}';
}

/// [value] を2桁にゼロ埋めした文字列に変換する。
String _twoDigits(final int value) => value.toString().padLeft(2, '0');

/// [value] に含まれる全角数字（`０`〜`９`）・全角コロン（`：`）を半角に変換
/// する。
String _toHalfWidth(final String value) {
  const int fullWidthZero = 0xFF10;
  const int fullWidthNine = 0xFF19;
  const int fullWidthColon = 0xFF1A;
  const int halfWidthOffset = 0xFEE0;
  return String.fromCharCodes(
    value.runes.map((final int rune) {
      if ((rune >= fullWidthZero && rune <= fullWidthNine) ||
          rune == fullWidthColon) {
        return rune - halfWidthOffset;
      }
      return rune;
    }),
  );
}
