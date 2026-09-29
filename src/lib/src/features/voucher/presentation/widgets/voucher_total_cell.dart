import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/enums/enums.dart';

/// 伝票入力画面のグリッド内で1行分の「合計金額」列セルを表すウィジェット。
///
/// [amount]を太字で表示し、隣に決済方法（PayPay／カード）のトグルボタンを
/// 配置する。どちらも選択されていない場合は現金決済を意味する。
class VoucherTotalCell extends StatelessWidget {
  /// [VoucherTotalCell] を生成する。
  const VoucherTotalCell({
    required this.amount,
    required this.paymentMethod,
    required this.onPaymentMethodChanged,
    super.key,
  });

  /// 合計金額。
  final int amount;

  /// 現在選択中の決済方法。`null`は現金決済。
  final PaymentMethod? paymentMethod;

  /// 決済方法変更時コールバック。
  final ValueChanged<PaymentMethod?> onPaymentMethodChanged;

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IntProperty('amount', amount))
      ..add(
        EnumProperty<PaymentMethod?>('paymentMethod', paymentMethod),
      )
      ..add(
        ObjectFlagProperty<ValueChanged<PaymentMethod?>>.has(
          'onPaymentMethodChanged',
          onPaymentMethodChanged,
        ),
      );
  }

  @override
  Widget build(final BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('¥$amount'),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _paymentChip(context, 'P', PaymentMethod.paypay),
                const SizedBox(width: 4),
                _paymentChip(context, 'カ', PaymentMethod.card),
              ],
            ),
          ],
        ),
      );

  Widget _paymentChip(
    final BuildContext context,
    final String label,
    final PaymentMethod method,
  ) {
    final bool active = paymentMethod == method;
    return InkWell(
      onTap: () => onPaymentMethodChanged(active ? null : method),
      child: Container(
        width: 20,
        height: 18,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: active
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
