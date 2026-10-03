import '../../../../core/errors/record_not_found_exception.dart';
import '../entities/customer.dart';
import '../entities/daily_payment_summary.dart';
import '../entities/header.dart';
import '../entities/header_price.dart';
import '../entities/sheet_cell.dart';
import '../entities/sheet_detail.dart';
import '../entities/sheet_instance.dart';
import '../entities/sheet_row.dart';
import '../entities/staff.dart';
import '../entities/staff_shift.dart';
import '../repositories/customer_repository.dart';
import '../repositories/daily_payment_summary_repository.dart';
import '../repositories/header_price_repository.dart';
import '../repositories/header_repository.dart';
import '../repositories/sheet_cell_repository.dart';
import '../repositories/sheet_instance_repository.dart';
import '../repositories/sheet_row_repository.dart';
import '../repositories/staff_repository.dart';
import '../repositories/staff_shift_repository.dart';

/// 伝票入力画面（`MMM_001_VOUCHER`）の描画に必要な情報一式を[SheetDetail]と
/// して取得するユースケース。行×列の参照をO(1)にするための事前変換を行う。
class GetSheetDetailUsecase {
  /// [GetSheetDetailUsecase] を生成する。
  const GetSheetDetailUsecase({
    required final SheetInstanceRepository instanceRepository,
    required final HeaderRepository headerRepository,
    required final SheetRowRepository rowRepository,
    required final SheetCellRepository cellRepository,
    required final StaffShiftRepository staffShiftRepository,
    required final DailyPaymentSummaryRepository dailyPaymentSummaryRepository,
    required final StaffRepository staffRepository,
    required final CustomerRepository customerRepository,
    required final HeaderPriceRepository headerPriceRepository,
  })  : _instanceRepository = instanceRepository,
        _headerRepository = headerRepository,
        _rowRepository = rowRepository,
        _cellRepository = cellRepository,
        _staffShiftRepository = staffShiftRepository,
        _dailyPaymentSummaryRepository = dailyPaymentSummaryRepository,
        _staffRepository = staffRepository,
        _customerRepository = customerRepository,
        _headerPriceRepository = headerPriceRepository;

  final SheetInstanceRepository _instanceRepository;
  final HeaderRepository _headerRepository;
  final SheetRowRepository _rowRepository;
  final SheetCellRepository _cellRepository;
  final StaffShiftRepository _staffShiftRepository;
  final DailyPaymentSummaryRepository _dailyPaymentSummaryRepository;
  final StaffRepository _staffRepository;
  final CustomerRepository _customerRepository;
  final HeaderPriceRepository _headerPriceRepository;

  /// 指定した伝票インスタンスの列一覧・行一覧・セル一覧を取得し、画面表示用
  /// に[SheetDetail]として組み立てる。
  Future<SheetDetail> call(final String sheetInstanceId) async {
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

    final Map<String, Map<String, SheetCell>> cellsByRowIdAndColumnId =
        <String, Map<String, SheetCell>>{};
    for (final SheetCell cell in cells) {
      cellsByRowIdAndColumnId.putIfAbsent(
        cell.rowId,
        () => <String, SheetCell>{},
      )[cell.columnId] = cell;
    }

    final List<StaffShift> staffShifts =
        await _staffShiftRepository.findByInstanceId(sheetInstanceId);
    final DailyPaymentSummary dailySummary =
        await _dailyPaymentSummaryRepository.getByInstanceId(
      sheetInstanceId,
      instance.businessDate,
    );
    final List<Staff> staffRoster = await _staffRepository.findAllActive();

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
    // 本伝票の営業日より前に来店履歴がない顧客を新規客とする。
    final List<String> visitedCustomerIds =
        await _rowRepository.findCustomerIdsVisitedBefore(
      customerIds,
      instance.businessDate,
    );
    final Set<String> newCustomerIds = customerIds.toSet()
      ..removeAll(visitedCustomerIds);

    final Map<String, int> unitPricesByColumnId = <String, int>{};
    for (final Header header in headers) {
      if (!header.isPriced) {
        continue;
      }
      try {
        final HeaderPrice currentPrice = await _headerPriceRepository
            .findCurrentPrice(header.columnId, instance.businessDate);
        unitPricesByColumnId[header.columnId] = currentPrice.price;
      } on RecordNotFoundException {
        // 単価未登録の列は表示上「単価なし」として扱う。
      }
    }

    return SheetDetail(
      sheetInstance: instance,
      headers: headers,
      rows: rows,
      cellsByRowIdAndColumnId: cellsByRowIdAndColumnId,
      staffShifts: staffShifts,
      dailySummary: dailySummary,
      staffRoster: staffRoster,
      customersById: customersById,
      unitPricesByColumnId: unitPricesByColumnId,
      newCustomerIds: newCustomerIds,
    );
  }
}
