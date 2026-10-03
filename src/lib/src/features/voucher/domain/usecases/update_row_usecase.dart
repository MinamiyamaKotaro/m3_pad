import '../../../../core/utils/id_generator.dart';
import '../entities/customer.dart';
import '../entities/enums/enums.dart';
import '../entities/sheet_row.dart';
import '../repositories/customer_repository.dart';
import '../repositories/sheet_row_repository.dart';

/// 行作成後に発生する3種類の更新（「お名前」列の編集、「担当」列プルダウン
/// でのスタッフ再選択、「合計金額」列に隣接する「P」「カ」決済方法の丸付け）
/// をまとめて扱うユースケース。
///
/// 更新対象以外は現在値を維持する部分更新方式を採る。
class UpdateRowUsecase {
  /// [UpdateRowUsecase] を生成する。
  const UpdateRowUsecase({
    required final SheetRowRepository rowRepository,
    required final CustomerRepository customerRepository,
    required final IdGenerator idGenerator,
  })  : _rowRepository = rowRepository,
        _customerRepository = customerRepository,
        _idGenerator = idGenerator;

  final SheetRowRepository _rowRepository;
  final CustomerRepository _customerRepository;
  final IdGenerator _idGenerator;

  /// [current] の顧客紐付け・担当スタッフ・決済方法のうち、指定された項目
  /// のみを更新する。
  ///
  /// - [customerName]: 「お名前」列を編集した場合のみ指定。空文字列は
  ///   「未登録（新規客）」を意味する。`null`（未指定）の場合は変更しない。
  ///   既に同名の有効な顧客が存在する場合はその顧客に紐付け、重複した
  ///   [Customer]は作成しない。存在しない場合のみ新規に作成する。
  /// - [staffId]: 「担当」列を変更した場合のみ`Some`を渡す（[hasStaffId]）。
  /// - [paymentMethod]: 決済方法を変更した場合のみ`Some`を渡す
  ///   （[hasPaymentMethod]）。
  Future<SheetRow> call(
    final SheetRow current, {
    final String? customerName,
    final String? staffId,
    final bool hasStaffId = false,
    final PaymentMethod? paymentMethod,
    final bool hasPaymentMethod = false,
  }) async {
    String? customerId = current.customerId;
    if (customerName != null) {
      if (customerName.isEmpty) {
        customerId = null;
      } else if (current.customerId == null) {
        final Customer? existing = await _customerRepository.findByName(
          customerName,
        );
        if (existing != null) {
          customerId = existing.customerId;
        } else {
          final String newCustomerId = _idGenerator.generate();
          final DateTime now = DateTime.now();
          await _customerRepository.insert(
            Customer(
              customerId: newCustomerId,
              name: customerName,
              gender: Gender.none,
              status: RecordStatus.active,
              createdAt: now,
              updatedAt: now,
            ),
          );
          customerId = newCustomerId;
        }
      }
    }

    final String? resolvedStaffId = hasStaffId ? staffId : current.staffId;
    final PaymentMethod? resolvedPaymentMethod =
        hasPaymentMethod ? paymentMethod : current.paymentMethod;

    final SheetRow updated = SheetRow(
      rowId: current.rowId,
      sheetInstanceId: current.sheetInstanceId,
      customerId: customerId,
      staffId: resolvedStaffId,
      rowOrder: current.rowOrder,
      totalAmount: current.totalAmount,
      paymentMethod: resolvedPaymentMethod,
      status: current.status,
      createdAt: current.createdAt,
      updatedAt: DateTime.now(),
    );
    await _rowRepository.update(updated);
    return updated;
  }
}
