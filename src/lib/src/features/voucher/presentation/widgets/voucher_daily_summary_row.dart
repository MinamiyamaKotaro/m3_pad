import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/daily_payment_summary.dart';
import '../../domain/entities/header.dart';

/// 伝票の末尾の行として、その日の合計金額と決済方法別内訳（現金／カード／
/// PayPay）を表示するウィジェット（FR-2）。
///
/// 列構成はヘッダー行に合わせ、「お名前」列位置にラベル「本日の合計」を
/// 表示し、価格列・MEMO列は空欄、「合計金額」列位置に金額と内訳、
/// 「担当」列位置は空欄とする。
class VoucherDailySummaryRow extends StatelessWidget {
  /// [VoucherDailySummaryRow] を生成する。
  const VoucherDailySummaryRow({
    required this.summary,
    required this.headers,
    super.key,
  });

  /// 日次集計。
  final DailyPaymentSummary summary;

  /// 列一覧。空欄セルの列数をヘッダー行と揃えるために使用する。
  final List<Header> headers;

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<DailyPaymentSummary>('summary', summary))
      ..add(IterableProperty<Header>('headers', headers));
  }

  @override
  Widget build(final BuildContext context) => ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Row(
          children: <Widget>[
            const SizedBox(
              width: 96,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text('本日の合計', textAlign: TextAlign.right),
              ),
            ),
            SizedBox(width: 96.0 * headers.length),
            SizedBox(width: 96, child: _buildTotal(context)),
            const SizedBox(width: 96),
          ],
        ),
      );

  Widget _buildTotal(final BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            '¥${summary.totalAmount}',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text('現金 ¥${summary.cashAmount}', style: _smallStyle(context)),
          Text('カード ¥${summary.cardAmount}', style: _smallStyle(context)),
          Text('PayPay ¥${summary.paypayAmount}', style: _smallStyle(context)),
        ],
      );

  TextStyle? _smallStyle(final BuildContext context) =>
      Theme.of(context).textTheme.labelSmall;
}
