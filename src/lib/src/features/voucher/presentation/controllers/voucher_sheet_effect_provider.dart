import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'voucher_sheet_effect.dart';

/// [VoucherSheetEffect] を1回限りの通知として保持するNotifier。
///
/// VoucherSheetPageが`ref.listen`で購読し、通知のたびに副作用（お知らせ
/// バナー表示・共有シート表示等）を処理する。
class VoucherSheetEffectNotifier extends Notifier<VoucherSheetEffect?> {
  @override
  VoucherSheetEffect? build() => null;

  /// [effect] を発行する。単なる代入ではなく「1回限りの通知を発行する」と
  /// いう操作の意味を明示するため、setterではなくメソッドとする。
  // ignore: use_setters_to_change_properties
  void emit(final VoucherSheetEffect effect) {
    state = effect;
  }
}

/// [VoucherSheetEffectNotifier] を提供するプロバイダ。
final NotifierProvider<VoucherSheetEffectNotifier, VoucherSheetEffect?>
    voucherSheetEffectProvider =
    NotifierProvider<VoucherSheetEffectNotifier, VoucherSheetEffect?>(
  VoucherSheetEffectNotifier.new,
);
