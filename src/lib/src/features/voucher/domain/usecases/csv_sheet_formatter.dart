/// CSV出力（[ExportDailySheetToCsvUsecase](./export_daily_sheet_to_csv_usecase.dart)・
/// [ExportSheetsToCsvByDateRangeUsecase](./export_sheets_to_csv_by_date_range_usecase.dart)）
/// で共有する行組み立てロジック。
///
/// 列構成は「営業日」「お名前」＋紙伝票の各列（価格列＋MEMO列）＋
/// 「合計金額」「担当」の順で固定する。紙伝票の各列は、伝票入力画面と同じく
/// 同額の列を1グループ（[groupHeadersByPrice]）として1列に出力する。
library;

import '../../../../core/utils/sqlite_date.dart';
import '../entities/customer.dart';
import '../entities/header.dart';
import '../entities/sheet_cell.dart';
import '../entities/sheet_instance.dart';
import '../entities/sheet_row.dart';
import '../entities/staff.dart';
import 'header_grouping.dart';

/// ヘッダー行（1行目）を組み立てる。
///
/// [headerGroups]（[groupHeadersByPrice]の戻り値）の各グループを1列とし、
/// 見出しはグループ内の列名を`/`で連結する（例: `お茶ハイ/ソフトドリンク`）。
List<String> csvHeaderLine(final List<List<Header>> headerGroups) => <String>[
      escapeCsvValue('営業日'),
      escapeCsvValue('お名前'),
      ...headerGroups.map(
        (final List<Header> group) => escapeCsvValue(
          group.map((final Header header) => header.name).join('/'),
        ),
      ),
      escapeCsvValue('合計金額'),
      escapeCsvValue('担当'),
    ];

/// 1営業日・1行分（[instance]・[row]）のCSV行を組み立てる。
///
/// [cellByRowAndColumn]は`'$rowId:$columnId'`をキーとしたセルMap、
/// [customersById]・[staffById]はそれぞれ`customerId`・`staffId`を
/// キーとしたMap（呼び出し側で事前に構築し、繰り返し内でのDB呼び出しを
/// 避ける）。
///
/// 価格対象のグループはグループ内の各列のセルの金額（`amount`）の合計を、
/// MEMO列はセルの内容を出力する。グループ内にセルが1つもない場合は空欄と
/// する。
String csvRowLine({
  required final SheetInstance instance,
  required final SheetRow row,
  required final List<List<Header>> headerGroups,
  required final Map<String, SheetCell> cellByRowAndColumn,
  required final Map<String, Customer> customersById,
  required final Map<String, Staff> staffById,
}) {
  final Customer? customer =
      row.customerId == null ? null : customersById[row.customerId];
  final Staff? staff = row.staffId == null ? null : staffById[row.staffId];
  final List<String> values = <String>[
    escapeCsvValue(formatDateOnly(instance.businessDate)),
    escapeCsvValue(customer?.name ?? ''),
    ...headerGroups.map((final List<Header> group) {
      final List<SheetCell> cells = group
          .map(
            (final Header header) =>
                cellByRowAndColumn['${row.rowId}:${header.columnId}'],
          )
          .whereType<SheetCell>()
          .toList();
      if (cells.isEmpty) {
        return '';
      }
      if (!group.first.isPriced) {
        return escapeCsvValue(cells.first.content ?? '');
      }
      final int amount = cells.fold(
        0,
        (final int sum, final SheetCell cell) => sum + (cell.amount ?? 0),
      );
      return escapeCsvValue(amount.toString());
    }),
    escapeCsvValue(row.totalAmount.toString()),
    escapeCsvValue(staff?.name ?? ''),
  ];
  return values.join(',');
}

/// CSVの値として安全な形にエスケープする。
String escapeCsvValue(final String value) {
  if (value.contains(',') || value.contains('"') || value.contains('\n')) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}
