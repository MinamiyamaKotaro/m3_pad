import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/currency_format.dart';
import '../../domain/entities/enums/enums.dart';
import '../../domain/entities/header.dart';
import '../../domain/usecases/header_grouping.dart';

/// カテゴリーごとの文字色（FR-6、視認性優先の色分け）。背景色は変えず、
/// 文字色のみで区別する。
const Map<HeaderCategory, Color> _categoryTextColors = <HeaderCategory, Color>{
  HeaderCategory.drink: Color(0xFF0B63B0),
  HeaderCategory.bottle: Color(0xFF7A2FB0),
  HeaderCategory.food: Color(0xFF1E7A32),
};

/// 伝票入力画面の列名・単価を固定表示するヘッダー行ウィジェット。
///
/// 紙伝票のヘッダー行固定表示（FR-1）に対応する。現在の単価が同額の列の
/// グループ（[groupHeadersByPrice]の戻り値）ごとに1つのセルを描画し、
/// グループ内の列名を改行して並べる（FR-6）。列名はそれぞれの列の
/// カテゴリーの文字色で表示する（背景色は変えない）。単価はグループ内の
/// カテゴリーが1種類の場合はそのカテゴリーの文字色、複数のカテゴリーが
/// 混在する場合は黒色で表示する。列名・単価はカテゴリーによらず全て太字
/// で表示する。グループの組み立て・並び順・非表示列の除外は呼び出し元
/// （[VoucherSheetGrid](./voucher_sheet_grid.dart)）が行う。画面内で
/// のみ使用する。
class VoucherHeaderRow extends StatelessWidget {
  /// [VoucherHeaderRow] を生成する。
  const VoucherHeaderRow({
    required this.headerGroups,
    required this.unitPricesByColumnId,
    super.key,
  });

  /// 1列あたりの幅。グループのセル幅は「列数×本値」とする。
  static const double columnWidth = 96;

  /// 同額の列のグループ一覧（表示対象の列のみ・描画順）。
  final List<List<Header>> headerGroups;

  /// 列ID別の現在の適用単価Map。`SheetDetail.unitPricesByColumnId`。
  final Map<String, int> unitPricesByColumnId;

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IterableProperty<List<Header>>('headerGroups', headerGroups))
      ..add(
        DiagnosticsProperty<Map<String, int>>(
          'unitPricesByColumnId',
          unitPricesByColumnId,
        ),
      );
  }

  /// [group] の単価の文字色。カテゴリーが1種類の場合はそのカテゴリーの
  /// 文字色（カテゴリーなしの場合は既定色）、複数混在する場合は黒色。
  Color? _priceColor(final BuildContext context, final List<Header> group) {
    final Set<HeaderCategory> categories = <HeaderCategory>{
      for (final Header header in group) header.category,
    };
    if (categories.length > 1) {
      return Theme.of(context).colorScheme.onSurface;
    }
    return _categoryTextColors[group.first.category];
  }

  @override
  Widget build(final BuildContext context) {
    final Color outline = Theme.of(context).colorScheme.outline;
    final Color surface = Theme.of(context).colorScheme.surface;
    final TextStyle? nameStyle = Theme.of(context)
        .textTheme
        .labelMedium
        ?.copyWith(fontWeight: FontWeight.bold);
    return DecoratedBox(
      decoration: BoxDecoration(color: surface),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: headerGroups.map((final List<Header> group) {
          final int? price = group.first.isPriced
              ? unitPricesByColumnId[group.first.columnId]
              : null;
          return Container(
            width: columnWidth * group.length,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            decoration: BoxDecoration(
              color: surface,
              border: Border(
                right: BorderSide(color: outline),
                bottom: BorderSide(color: outline),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text.rich(
                  TextSpan(
                    children: <InlineSpan>[
                      for (int i = 0; i < group.length; i++)
                        TextSpan(
                          text: i == 0 ? group[i].name : '\n${group[i].name}',
                          style: TextStyle(
                            color: _categoryTextColors[group[i].category],
                          ),
                        ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: nameStyle,
                ),
                if (price != null)
                  Text(
                    formatYen(price),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _priceColor(context, group),
                        ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
