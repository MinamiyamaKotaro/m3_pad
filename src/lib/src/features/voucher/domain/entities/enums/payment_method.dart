/// 決済方法（DB上の`t_row.payment_method`カラム）をアプリ層で型安全に
/// 扱うためのenum。現金決済は専用の値を持たず、`null`で表現する。
enum PaymentMethod {
  /// PayPay決済。
  paypay,

  /// カード決済。
  card;

  /// DB値（`'paypay'` / `'card'`）から [PaymentMethod] へ変換する。
  static PaymentMethod fromDbValue(final String value) =>
      PaymentMethod.values.firstWhere(
        (final PaymentMethod method) => method.dbValue == value,
      );

  /// DB保存用の値（`'paypay'` / `'card'`）。
  String get dbValue => name;
}
