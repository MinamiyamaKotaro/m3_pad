import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/staff.dart';

/// 伝票入力画面のグリッド内で1行分の「担当」列セルを表すウィジェット。
///
/// 会計を行ったスタッフをプルダウンで選択する。決済方法の「P」「カ」とは
/// 別概念である。
class VoucherStaffSelectCell extends StatelessWidget {
  /// [VoucherStaffSelectCell] を生成する。
  const VoucherStaffSelectCell({
    required this.staffId,
    required this.staffRoster,
    required this.onChanged,
    super.key,
  });

  /// 選択中のスタッフID。未定の場合は`null`。
  final String? staffId;

  /// スタッフ選択肢一覧。
  final List<Staff> staffRoster;

  /// 選択変更時コールバック。
  final ValueChanged<String?> onChanged;

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('staffId', staffId))
      ..add(IterableProperty<Staff>('staffRoster', staffRoster))
      ..add(
        ObjectFlagProperty<ValueChanged<String?>>.has('onChanged', onChanged),
      );
  }

  @override
  Widget build(final BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String?>(
            // 一覧にない（論理削除済みの）スタッフは「未定」として表示する。
            value:
                staffRoster.any((final Staff staff) => staff.staffId == staffId)
                    ? staffId
                    : null,
            isDense: true,
            isExpanded: true,
            hint: const Text('未定'),
            items: <DropdownMenuItem<String?>>[
              const DropdownMenuItem<String?>(child: Text('未定')),
              ...staffRoster.map(
                (final Staff staff) => DropdownMenuItem<String?>(
                  value: staff.staffId,
                  child: Text(staff.name),
                ),
              ),
            ],
            onChanged: onChanged,
          ),
        ),
      );
}
