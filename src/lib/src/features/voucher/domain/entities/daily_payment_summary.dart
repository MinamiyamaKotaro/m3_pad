/// 伝票末尾の行に表示する、その日（営業日）の合計金額と決済方法別内訳
/// （現金／カード／PayPay）を表す読み取り専用の集約エンティティ。
///
/// 永続テーブルは持たず、DBのビュー`v_daily_payment_summary`から取得する。
class DailyPaymentSummary {
  /// [DailyPaymentSummary] を生成する。
  const DailyPaymentSummary({
    required this.sheetInstanceId,
    required this.businessDate,
    required this.totalAmount,
    required this.cashAmount,
    required this.cardAmount,
    required this.paypayAmount,
  });

  /// 伝票インスタンスID。
  final String sheetInstanceId;

  /// 営業日（日付のみ）。
  final DateTime businessDate;

  /// 合計金額。行が0件の場合は0。
  final int totalAmount;

  /// 現金内訳。`paymentMethod`が`null`の行の合計。
  final int cashAmount;

  /// カード内訳。`paymentMethod=card`の行の合計。
  final int cardAmount;

  /// PayPay内訳。`paymentMethod=paypay`の行の合計。
  final int paypayAmount;
}
