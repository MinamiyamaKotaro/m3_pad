import '../../../../core/utils/sqlite_date.dart';
import '../entities/customer.dart';
import '../entities/header.dart';
import '../entities/sheet_cell.dart';
import '../entities/sheet_instance.dart';
import '../entities/sheet_row.dart';
import '../entities/staff.dart';
import '../repositories/customer_repository.dart';
import '../repositories/header_repository.dart';
import '../repositories/sheet_cell_repository.dart';
import '../repositories/sheet_instance_repository.dart';
import '../repositories/sheet_row_repository.dart';
import '../repositories/staff_repository.dart';

/// 指定した伝票インスタンス（1営業日分の伝票）を、紙伝票と同じ列構成の
/// CSVとして出力するユースケース（FR-3）。
///
/// 列構成は「営業日」「お名前」＋紙伝票の各列（価格列＋MEMO列）＋
/// 「合計金額」「担当」の順とする。行数×列数に対して線形の計算量になる
/// よう、セルは`(rowId, columnId)`をキーとしたMapへ事前変換してから参照
/// する（O(n^2)の回避）。CSV文字列の組み立てまでを責務とし、ファイルへの
/// 書き出し・共有はpresentation層が行う。
class ExportDailySheetToCsvUsecase {
  /// [ExportDailySheetToCsvUsecase] を生成する。
  const ExportDailySheetToCsvUsecase({
    required final SheetInstanceRepository instanceRepository,
    required final HeaderRepository headerRepository,
    required final SheetRowRepository rowRepository,
    required final SheetCellRepository cellRepository,
    required final CustomerRepository customerRepository,
    required final StaffRepository staffRepository,
  })  : _instanceRepository = instanceRepository,
        _headerRepository = headerRepository,
        _rowRepository = rowRepository,
        _cellRepository = cellRepository,
        _customerRepository = customerRepository,
        _staffRepository = staffRepository;

  final SheetInstanceRepository _instanceRepository;
  final HeaderRepository _headerRepository;
  final SheetRowRepository _rowRepository;
  final SheetCellRepository _cellRepository;
  final CustomerRepository _customerRepository;
  final StaffRepository _staffRepository;

  /// 指定した [sheetInstanceId] の伝票インスタンスをCSV文字列として出力する。
  ///
  /// 1行目が列名（ヘッダー）、2行目以降が行データ。
  Future<String> call(final String sheetInstanceId) async {
    final SheetInstance instance = await _instanceRepository.findById(
      sheetInstanceId,
    );
    final List<Header> headers = await _headerRepository.findByTemplateId(
      instance.sheetTemplateId,
    );
    final List<SheetRow> rows = await _rowRepository.findByInstanceId(
      sheetInstanceId,
    );
    final List<String> rowIds =
        rows.map((final SheetRow row) => row.rowId).toList();
    final List<SheetCell> cells = await _cellRepository.findByRowIds(rowIds);

    final Map<String, SheetCell> cellByRowAndColumn = <String, SheetCell>{
      for (final SheetCell cell in cells)
        '${cell.rowId}:${cell.columnId}': cell,
    };

    final List<String> customerIds = rows
        .map((final SheetRow row) => row.customerId)
        .whereType<String>()
        .toList();
    final List<Customer> customers = await _customerRepository.findByIds(
      customerIds,
    );
    final Map<String, Customer> customersById = <String, Customer>{
      for (final Customer customer in customers) customer.customerId: customer,
    };
    final List<Staff> staffRoster = await _staffRepository.findAllActive();
    final Map<String, Staff> staffById = <String, Staff>{
      for (final Staff staff in staffRoster) staff.staffId: staff,
    };

    final String businessDate = formatDateOnly(instance.businessDate);
    final List<String> headerLine = <String>[
      _escape('営業日'),
      _escape('お名前'),
      ...headers.map((final Header header) => _escape(header.name)),
      _escape('合計金額'),
      _escape('担当'),
    ];

    final List<String> rowLines = rows.map((final SheetRow row) {
      final Customer? customer =
          row.customerId == null ? null : customersById[row.customerId];
      final Staff? staff = row.staffId == null ? null : staffById[row.staffId];
      final List<String> values = <String>[
        _escape(businessDate),
        _escape(customer?.name ?? ''),
        ...headers.map((final Header header) {
          final SheetCell? cell =
              cellByRowAndColumn['${row.rowId}:${header.columnId}'];
          if (cell == null) {
            return '';
          }
          return header.isPriced
              ? _escape((cell.amount ?? 0).toString())
              : _escape(cell.content ?? '');
        }),
        _escape(row.totalAmount.toString()),
        _escape(staff?.name ?? ''),
      ];
      return values.join(',');
    }).toList();

    return <String>[headerLine.join(','), ...rowLines].join('\n');
  }

  String _escape(final String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
