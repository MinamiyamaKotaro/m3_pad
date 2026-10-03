/// 伝票の列（[Header]）を、現在の単価が同額のもの同士で1グループにまとめる
/// ロジック。
///
/// 伝票入力画面（ヘッダー行のグルーピング表示・グループにつき1つの個数
/// セル）とCSV出力（グループ単位の列）で共有する。
library;

import '../entities/header.dart';

/// [headers] を、同額の価格対象の列ごとのグループに分けて描画順に並べる。
///
/// 1. 価格対象の列（`isPriced=true`）のうち、[unitPricesByColumnId] の単価
///    が同額のものを1グループにまとめる。グループの並びは価格ごとの初出順、
///    グループ内の並びは [headers] の順を保つ。
/// 2. 単価未登録の価格対象の列は、それぞれ単独のグループとして元の位置を
///    保つ。
/// 3. 非価格対象の列（MEMO）は、それぞれ単独のグループとして常に価格対象の
///    列より後ろに並べる。
///
/// グループの先頭の列（`group.first`）を、グループの個数を保存する代表列
/// とする。
List<List<Header>> groupHeadersByPrice(
  final List<Header> headers,
  final Map<String, int> unitPricesByColumnId,
) {
  final Map<int, List<Header>> groupByPrice = <int, List<Header>>{};
  final List<List<Header>> pricedGroups = <List<Header>>[];
  final List<List<Header>> nonPricedGroups = <List<Header>>[];
  for (final Header header in headers) {
    if (!header.isPriced) {
      nonPricedGroups.add(<Header>[header]);
      continue;
    }
    final int? price = unitPricesByColumnId[header.columnId];
    if (price == null) {
      pricedGroups.add(<Header>[header]);
      continue;
    }
    final List<Header>? group = groupByPrice[price];
    if (group == null) {
      final List<Header> newGroup = <Header>[header];
      groupByPrice[price] = newGroup;
      pricedGroups.add(newGroup);
    } else {
      group.add(header);
    }
  }
  return <List<Header>>[...pricedGroups, ...nonPricedGroups];
}
