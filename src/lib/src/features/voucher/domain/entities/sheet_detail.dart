import 'customer.dart';
import 'daily_payment_summary.dart';
import 'header.dart';
import 'sheet_cell.dart';
import 'sheet_instance.dart';
import 'sheet_row.dart';
import 'staff.dart';
import 'staff_shift.dart';

/// 伝票入力画面（`MMM_001_VOUCHER`）の描画に必要なデータを1つに束ねた
/// 読み取り専用の集約DTO。
///
/// `SheetInstance`・`Header`一覧・`SheetRow`一覧・`SheetCell`・
/// `StaffShift`一覧・`DailyPaymentSummary`・スタッフ選択肢一覧を、行×列の
/// 参照がO(1)になるようネスト済みMapとして保持する。
class SheetDetail {
  /// [SheetDetail] を生成する。
  const SheetDetail({
    required this.sheetInstance,
    required this.headers,
    required this.rows,
    required this.cellsByRowIdAndColumnId,
    required this.staffShifts,
    required this.dailySummary,
    required this.staffRoster,
    required this.customersById,
    required this.unitPricesByColumnId,
  });

  /// 伝票インスタンス。
  final SheetInstance sheetInstance;

  /// 列一覧。`displayOrder`昇順。
  final List<Header> headers;

  /// 行一覧。`rowOrder`昇順。
  final List<SheetRow> rows;

  /// 行列キー別セルMap。外側キー=rowId、内側キー=columnId。
  final Map<String, Map<String, SheetCell>> cellsByRowIdAndColumnId;

  /// スタッフシフト一覧。右上「スタッフ」欄の表示用。
  final List<StaffShift> staffShifts;

  /// 日次集計。伝票末尾の行の表示用。
  final DailyPaymentSummary dailySummary;

  /// スタッフ選択肢一覧。「担当」列プルダウンおよびスタッフ欄の氏名
  /// プルダウンの選択肢として使用する。
  final List<Staff> staffRoster;

  /// 顧客ID別顧客Map。キー=customerId。「お名前」列の氏名表示用。
  final Map<String, Customer> customersById;

  /// 列ID別の現在の適用単価Map。キー=columnId。`isPriced=true`の列のみ
  /// キーが存在する。ヘッダー行の単価表示用。
  final Map<String, int> unitPricesByColumnId;
}
