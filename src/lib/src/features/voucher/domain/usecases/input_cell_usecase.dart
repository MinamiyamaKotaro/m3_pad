import '../../../../core/errors/validation_exception.dart';
import '../../../../core/utils/id_generator.dart';
import '../entities/header.dart';
import '../entities/header_price.dart';
import '../entities/sheet_cell.dart';
import '../entities/sheet_instance.dart';
import '../entities/sheet_row.dart';
import '../repositories/header_price_repository.dart';
import '../repositories/header_repository.dart';
import '../repositories/sheet_cell_repository.dart';
import '../repositories/sheet_instance_repository.dart';
import '../repositories/sheet_row_repository.dart';

/// 行と列の組に対応するセル（[SheetCell]）に値を入力するユースケース
/// （FR-2）。
///
/// 価格対象の列（`isPriced=true`）の場合、入力時点の適用単価を
/// [HeaderPrice] から取得してスナップショットし、数量×単価で金額を自動
/// 計算する。既存のセルがある場合は更新、ない場合は新規作成する。
class InputCellUsecase {
  /// [InputCellUsecase] を生成する。
  const InputCellUsecase({
    required final SheetRowRepository rowRepository,
    required final SheetInstanceRepository instanceRepository,
    required final HeaderRepository headerRepository,
    required final HeaderPriceRepository headerPriceRepository,
    required final SheetCellRepository cellRepository,
    required final IdGenerator idGenerator,
  })  : _rowRepository = rowRepository,
        _instanceRepository = instanceRepository,
        _headerRepository = headerRepository,
        _headerPriceRepository = headerPriceRepository,
        _cellRepository = cellRepository,
        _idGenerator = idGenerator;

  final SheetRowRepository _rowRepository;
  final SheetInstanceRepository _instanceRepository;
  final HeaderRepository _headerRepository;
  final HeaderPriceRepository _headerPriceRepository;
  final SheetCellRepository _cellRepository;
  final IdGenerator _idGenerator;

  /// [rowId]・[columnId] に対応するセルへ値を入力する。
  ///
  /// 列の[Header.isPriced]に応じて[content]（文字列列）または[quantity]
  /// （価格対象列）のいずれかを指定する。
  Future<SheetCell> call({
    required final String rowId,
    required final String columnId,
    final String? content,
    final int? quantity,
  }) async {
    final SheetRow row = await _rowRepository.findById(rowId);
    final SheetInstance sheetInstance = await _instanceRepository.findById(
      row.sheetInstanceId,
    );
    final Header header = await _headerRepository.findById(columnId);
    final SheetCell? existingCell =
        await _cellRepository.findByRowAndColumn(rowId, columnId);

    int? amount;
    int? unitPriceApplied;
    String? resolvedContent;
    if (header.isPriced) {
      if (quantity == null) {
        throw const ValidationException(reason: '数量は必須です');
      }
      final HeaderPrice currentPrice = await _headerPriceRepository
          .findCurrentPrice(columnId, sheetInstance.businessDate);
      unitPriceApplied = currentPrice.price;
      amount = quantity * currentPrice.price;
      resolvedContent = null;
    } else {
      if (content == null) {
        throw const ValidationException(reason: '内容は必須です');
      }
      resolvedContent = content;
    }

    final DateTime now = DateTime.now();
    final SheetCell cell;
    if (existingCell != null) {
      cell = SheetCell(
        cellId: existingCell.cellId,
        rowId: rowId,
        columnId: columnId,
        content: resolvedContent,
        quantity: header.isPriced ? quantity : null,
        unitPriceApplied: unitPriceApplied,
        amount: amount,
        createdAt: existingCell.createdAt,
        updatedAt: now,
      );
      await _cellRepository.update(cell);
    } else {
      final String cellId = _idGenerator.generate();
      cell = SheetCell(
        cellId: cellId,
        rowId: rowId,
        columnId: columnId,
        content: resolvedContent,
        quantity: header.isPriced ? quantity : null,
        unitPriceApplied: unitPriceApplied,
        amount: amount,
        createdAt: now,
        updatedAt: now,
      );
      await _cellRepository.insert(cell);
    }
    return cell;
  }
}
