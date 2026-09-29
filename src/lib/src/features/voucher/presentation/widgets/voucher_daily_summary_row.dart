import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/daily_payment_summary.dart';

/// 伝票入力画面のグリッド末尾（本日の合計行）の「合計金額」列セルとして、
/// その日の合計金額と決済方法別内訳（現金／カード／PayPay）を表示する
/// ウィジェット（FR-2）。
class VoucherDailySummaryRow extends StatelessWidget {
  /// [VoucherDailySummaryRow] を生成する。
  const VoucherDailySummaryRow({required this.summary, super.key});

  /// 日次集計。
  final DailyPaymentSummary summary;

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<DailyPaymentSummary>('summary', summary),
    );
  }

  @override
  Widget build(final BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '¥${summary.totalAmount}',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text('現金 ¥${summary.cashAmount}', style: _smallStyle(context)),
            Text('カード ¥${summary.cardAmount}', style: _smallStyle(context)),
            Text(
              'PayPay ¥${summary.paypayAmount}',
              style: _smallStyle(context),
            ),
          ],
        ),
      );

  TextStyle? _smallStyle(final BuildContext context) =>
      Theme.of(context).textTheme.labelSmall;
}
