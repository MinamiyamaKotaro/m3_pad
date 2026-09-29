import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/currency_format.dart';
import '../../domain/entities/enums/enums.dart';
import '../../domain/entities/header.dart';

/// カテゴリーごとの文字色（FR-6、視認性優先の色分け）。背景色は変えず、
/// 文字色のみで区別する。
const Map<HeaderCategory, Color> _categoryTextColors = <HeaderCategory, Color>{
  HeaderCategory.drink: Color(0xFF0B63B0),
  HeaderCategory.bottle: Color(0xFF7A2FB0),
  HeaderCategory.food: Color(0xFF1E7A32),
};

/// 伝票入力画面の列名・単価を固定表示するヘッダー行ウィジェット。
///
/// 紙伝票のヘッダー行固定表示（FR-1）に対応する。現在の単価が同額の列は
/// 1つのセル内にまとめて改行表示し（FR-6）、カテゴリーごとに文字色を変える
/// （背景色は変えない）。列名はカテゴリーによらず全て太字で表示する。
/// 列の並び順（同額グルーピングのための並べ替え・MEMOを末尾に保つ処理）は
/// 呼び出し元（[VoucherSheetGrid](./voucher_sheet_grid.dart)）が行い、本
/// ウィジェットは受け取った順序のまま隣接する同額列を1セルにまとめる。
/// 表示対象の列（`isVisible=true`）のみを受け取る想定で、非表示列の除外も
/// [VoucherSheetGrid](./voucher_sheet_grid.dart)が行う。画面内でのみ使用
/// する。
class VoucherHeaderRow extends StatelessWidget {
  /// [VoucherHeaderRow] を生成する。
  const VoucherHeaderRow({
    required this.headers,
    required this.unitPricesByColumnId,
    super.key,
  });

  /// 列一覧（表示対象のみ）。`displayOrder`昇順。列名と、`isPriced=true`の
  /// 列は単価を表示する。
  final List<Header> headers;

  /// 列ID別の現在の適用単価Map。`SheetDetail.unitPricesByColumnId`。
  final Map<String, int> unitPricesByColumnId;

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IterableProperty<Header>('headers', headers))
      ..add(
        DiagnosticsProperty<Map<String, int>>(
          'unitPricesByColumnId',
          unitPricesByColumnId,
        ),
      );
  }

  /// 隣接する列のうち、現在の単価が同額のものを1グループにまとめる。
  List<List<Header>> _groupByPrice() {
    final List<List<Header>> groups = <List<Header>>[];
    for (final Header header in headers) {
      if (groups.isNotEmpty && _samePrice(groups.last.last, header)) {
        groups.last.add(header);
      } else {
        groups.add(<Header>[header]);
      }
    }
    return groups;
  }

  bool _samePrice(final Header a, final Header b) {
    if (!a.isPriced || !b.isPriced) {
      return false;
    }
    final int? priceA = unitPricesByColumnId[a.columnId];
    final int? priceB = unitPricesByColumnId[b.columnId];
    return priceA != null && priceA == priceB;
  }

  @override
  Widget build(final BuildContext context) {
    final Color outline = Theme.of(context).colorScheme.outline;
    final Color surface = Theme.of(context).colorScheme.surface;
    return DecoratedBox(
      decoration: BoxDecoration(color: surface),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _groupByPrice().map((final List<Header> group) {
          final Color? textColor = _categoryTextColors[group.first.category];
          return Container(
            width: 96.0 * group.length,
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
                Text(
                  group.map((final Header header) => header.name).join('\n'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                ),
                if (group.first.isPriced &&
                    unitPricesByColumnId.containsKey(group.first.columnId))
                  Text(
                    formatYen(unitPricesByColumnId[group.first.columnId]!),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: textColor,
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
