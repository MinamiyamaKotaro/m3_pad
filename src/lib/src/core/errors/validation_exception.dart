/// DBの制約（NOT NULL・CHECK等）では表現できない業務ルール違反が発生した場合に
/// usecase層が送出する共有の例外クラス。
class ValidationException implements Exception {
  /// [ValidationException] を生成する。
  const ValidationException({required this.reason});

  /// 違反内容の説明文（例:「isPriced=trueの列にはinitialPriceが必須です」）。
  final String reason;

  @override
  String toString() => 'ValidationException: $reason';
}
