/// CSV出力（[ExportDailySheetToCsvUsecase](./export_daily_sheet_to_csv_usecase.dart)・
/// [ExportSheetsToCsvByDateRangeUsecase](./export_sheets_to_csv_by_date_range_usecase.dart)）
/// で共有する行組み立てロジック。
///
/// 列構成は「営業日」「お名前」＋紙伝票の各列（価格列＋MEMO列）＋
/// 「合計金額」「担当」の順で固定する。
library;

import '../../../../core/utils/sqlite_date.dart';
import '../entities/customer.dart';
import '../entities/header.dart';
import '../entities/sheet_cell.dart';
import '../entities/sheet_instance.dart';
import '../entities/sheet_row.dart';
import '../entities/staff.dart';

/// ヘッダー行（1行目）を組み立てる。
List<String> csvHeaderLine(final List<Header> headers) => <String>[
      escapeCsvValue('営業日'),
      escapeCsvValue('お名前'),
      ...headers.map((final Header header) => escapeCsvValue(header.name)),
      escapeCsvValue('合計金額'),
      escapeCsvValue('担当'),
    ];

/// 1営業日・1行分（[instance]・[row]）のCSV行を組み立てる。
///
/// [cellByRowAndColumn]は`'$rowId:$columnId'`をキーとしたセルMap、
/// [customersById]・[staffById]はそれぞれ`customerId`・`staffId`を
/// キーとしたMap（呼び出し側で事前に構築し、繰り返し内でのDB呼び出しを
/// 避ける）。
String csvRowLine({
  required final SheetInstance instance,
  required final SheetRow row,
  required final List<Header> headers,
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
    ...headers.map((final Header header) {
      final SheetCell? cell =
          cellByRowAndColumn['${row.rowId}:${header.columnId}'];
      if (cell == null) {
        return '';
      }
      return header.isPriced
          ? escapeCsvValue((cell.amount ?? 0).toString())
          : escapeCsvValue(cell.content ?? '');
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
