import '../entities/header.dart';
import '../entities/sheet_cell.dart';
import '../entities/sheet_instance.dart';
import '../entities/sheet_row.dart';
import '../repositories/header_repository.dart';
import '../repositories/sheet_cell_repository.dart';
import '../repositories/sheet_instance_repository.dart';
import '../repositories/sheet_row_repository.dart';

/// 指定した伝票インスタンス（1営業日分の伝票）を、紙伝票と同じ列構成の
/// CSVとして出力するユースケース（FR-3）。
///
/// 行数×列数に対して線形の計算量になるよう、セルは`(rowId, columnId)`を
/// キーとしたMapへ事前変換してから参照する（O(n^2)の回避）。CSV文字列の
/// 組み立てまでを責務とし、ファイルへの書き出し・共有はpresentation層が
/// 行う。
class ExportDailySheetToCsvUsecase {
  /// [ExportDailySheetToCsvUsecase] を生成する。
  const ExportDailySheetToCsvUsecase({
    required final SheetInstanceRepository instanceRepository,
    required final HeaderRepository headerRepository,
    required final SheetRowRepository rowRepository,
    required final SheetCellRepository cellRepository,
  })  : _instanceRepository = instanceRepository,
        _headerRepository = headerRepository,
        _rowRepository = rowRepository,
        _cellRepository = cellRepository;

  final SheetInstanceRepository _instanceRepository;
  final HeaderRepository _headerRepository;
  final SheetRowRepository _rowRepository;
  final SheetCellRepository _cellRepository;

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

    final String headerLine =
        headers.map((final Header header) => _escape(header.name)).join(',');

    final List<String> rowLines = rows.map((final SheetRow row) {
      final List<String> values = headers.map((final Header header) {
        final SheetCell? cell =
            cellByRowAndColumn['${row.rowId}:${header.columnId}'];
        if (cell == null) {
          return '';
        }
        return header.isPriced
            ? _escape((cell.amount ?? 0).toString())
            : _escape(cell.content ?? '');
      }).toList();
      return values.join(',');
    }).toList();

    return <String>[headerLine, ...rowLines].join('\n');
  }

  String _escape(final String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
