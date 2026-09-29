import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/currency_format.dart';
import '../../domain/entities/header.dart';

/// 伝票入力画面の列名・単価を固定表示するヘッダー行ウィジェット。
///
/// 紙伝票のヘッダー行固定表示（FR-1）に対応する。画面内でのみ使用する。
class VoucherHeaderRow extends StatelessWidget {
  /// [VoucherHeaderRow] を生成する。
  const VoucherHeaderRow({
    required this.headers,
    required this.unitPricesByColumnId,
    super.key,
  });

  /// 列一覧。`displayOrder`昇順。列名と、`isPriced=true`の列は単価を
  /// 表示する。
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

  @override
  Widget build(final BuildContext context) {
    final Color outline = Theme.of(context).colorScheme.outline;
    return DecoratedBox(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: headers
            .map(
              (final Header header) => Container(
                width: 96,
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: outline),
                    bottom: BorderSide(color: outline),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      header.name,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    if (header.isPriced &&
                        unitPricesByColumnId.containsKey(header.columnId))
                      Text(
                        formatYen(unitPricesByColumnId[header.columnId]!),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
