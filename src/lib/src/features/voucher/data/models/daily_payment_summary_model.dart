import '../../../../core/utils/sqlite_date.dart';
import '../../domain/entities/daily_payment_summary.dart';

/// [DailyPaymentSummary] のデータ層表現。ビュー`v_daily_payment_summary`の
/// 1行から生成する`fromMap`を持つ。読み取り専用のため`toMap`は持たない。
class DailyPaymentSummaryModel extends DailyPaymentSummary {
  /// [DailyPaymentSummaryModel] を生成する。
  const DailyPaymentSummaryModel({
    required super.sheetInstanceId,
    required super.businessDate,
    required super.totalAmount,
    required super.cashAmount,
    required super.cardAmount,
    required super.paypayAmount,
  });

  /// `v_daily_payment_summary`の行から [DailyPaymentSummaryModel] を
  /// 生成する。
  factory DailyPaymentSummaryModel.fromMap(final Map<String, Object?> map) =>
      DailyPaymentSummaryModel(
        sheetInstanceId: map['sheet_instance_id']! as String,
        businessDate: parseDateOnly(map['business_date']! as String),
        totalAmount: map['total_amount']! as int,
        cashAmount: map['cash_amount']! as int,
        cardAmount: map['card_amount']! as int,
        paypayAmount: map['paypay_amount']! as int,
      );
}
