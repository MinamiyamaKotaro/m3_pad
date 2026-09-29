import '../../../../core/errors/validation_exception.dart';
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
import 'csv_sheet_formatter.dart';

/// 指定した期間（開始日〜終了日）に含まれる全ての伝票インスタンスを、1つの
/// CSV文字列としてまとめて出力するユースケース（FR-3）。
///
/// 列構成は[ExportDailySheetToCsvUsecase](./export_daily_sheet_to_csv_usecase.dart)
/// と同じ（「営業日」列で日付ごとの行を区別する）。期間内の営業日数に
/// 比例したDB呼び出しにならないよう、伝票インスタンス・行・セル・顧客の
/// 取得はそれぞれ1回のクエリで一括して行う。
class ExportSheetsToCsvByDateRangeUsecase {
  /// [ExportSheetsToCsvByDateRangeUsecase] を生成する。
  const ExportSheetsToCsvByDateRangeUsecase({
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

  /// 指定した伝票フォーマット（[sheetTemplateId]）の[from]〜[to]（両端含む）
  /// の営業日分をCSV文字列として出力する。
  ///
  /// 1行目が列名（ヘッダー）、2行目以降が営業日昇順・行順の行データ。
  Future<String> call({
    required final String sheetTemplateId,
    required final DateTime from,
    required final DateTime to,
  }) async {
    if (from.isAfter(to)) {
      throw const ValidationException(reason: '開始日は終了日以前を指定してください');
    }

    final List<SheetInstance> instances =
        await _instanceRepository.findByTemplateIdAndDateRange(
      sheetTemplateId,
      from,
      to,
    );
    if (instances.isEmpty) {
      throw const ValidationException(reason: '指定期間に該当する伝票がありません');
    }
    final Map<String, SheetInstance> instanceById = <String, SheetInstance>{
      for (final SheetInstance instance in instances)
        instance.sheetInstanceId: instance,
    };

    final List<Header> headers = await _headerRepository.findByTemplateId(
      sheetTemplateId,
    );

    final List<String> instanceIds = instances
        .map((final SheetInstance instance) => instance.sheetInstanceId)
        .toList();
    final List<SheetRow> rows = await _rowRepository.findByInstanceIds(
      instanceIds,
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

    final List<String> rowLines = rows
        .map(
          (final SheetRow row) => csvRowLine(
            instance: instanceById[row.sheetInstanceId]!,
            row: row,
            headers: headers,
            cellByRowAndColumn: cellByRowAndColumn,
            customersById: customersById,
            staffById: staffById,
          ),
        )
        .toList();

    return <String>[csvHeaderLine(headers).join(','), ...rowLines].join('\n');
  }
}
