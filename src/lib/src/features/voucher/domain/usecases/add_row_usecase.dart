import '../../../../core/utils/id_generator.dart';
import '../entities/enums/enums.dart';
import '../entities/sheet_row.dart';
import '../repositories/customer_repository.dart';
import '../repositories/sheet_row_repository.dart';
import '../repositories/staff_repository.dart';

/// 伝票インスタンスに1組の来店・卓（[SheetRow]）を追加するユースケース
/// （FR-1）。
class AddRowUsecase {
  /// [AddRowUsecase] を生成する。
  const AddRowUsecase({
    required final CustomerRepository customerRepository,
    required final StaffRepository staffRepository,
    required final SheetRowRepository rowRepository,
    required final IdGenerator idGenerator,
  })  : _customerRepository = customerRepository,
        _staffRepository = staffRepository,
        _rowRepository = rowRepository,
        _idGenerator = idGenerator;

  final CustomerRepository _customerRepository;
  final StaffRepository _staffRepository;
  final SheetRowRepository _rowRepository;
  final IdGenerator _idGenerator;

  /// 伝票インスタンスに1組の来店・卓を追加する。
  ///
  /// [customerId] は未登録の来店（「NEW様」等）の場合`null`。
  Future<SheetRow> call(
    final String sheetInstanceId, {
    final String? customerId,
    final String? staffId,
  }) async {
    if (customerId != null) {
      await _customerRepository.findById(customerId);
    }
    if (staffId != null) {
      await _staffRepository.findById(staffId);
    }

    final int maxRowOrder = await _rowRepository.findMaxRowOrder(
      sheetInstanceId,
    );
    final int rowOrder = maxRowOrder + 1;
    final String rowId = _idGenerator.generate();
    final DateTime now = DateTime.now();
    final SheetRow row = SheetRow(
      rowId: rowId,
      sheetInstanceId: sheetInstanceId,
      customerId: customerId,
      staffId: staffId,
      rowOrder: rowOrder,
      totalAmount: 0,
      status: RecordStatus.active,
      createdAt: now,
      updatedAt: now,
    );
    await _rowRepository.insert(row);
    return row;
  }
}
