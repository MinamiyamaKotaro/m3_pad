import 'package:sqflite/sqflite.dart';

import '../models/daily_payment_summary_model.dart';

/// ビュー`v_daily_payment_summary`に対する実際のSQL実行を担うローカル
/// データソース。読み取り専用のため更新用メソッドは持たない。
class DailyPaymentSummaryLocalDataSource {
  /// [DailyPaymentSummaryLocalDataSource] を生成する。
  const DailyPaymentSummaryLocalDataSource(this._db);

  final Database _db;

  /// [sheetInstanceId] に対応する日次集計を1件取得する。
  ///
  /// 該当行がない場合は、[businessDate] を用い金額項目をすべて0とした値を
  /// 組み立てて返す。
  Future<DailyPaymentSummaryModel> getByInstanceId(
    final String sheetInstanceId,
    final DateTime businessDate,
  ) async {
    final List<Map<String, Object?>> rows = await _db.query(
      'v_daily_payment_summary',
      where: 'sheet_instance_id = ?',
      whereArgs: <Object?>[sheetInstanceId],
    );
    if (rows.isEmpty) {
      return DailyPaymentSummaryModel(
        sheetInstanceId: sheetInstanceId,
        businessDate: businessDate,
        totalAmount: 0,
        cashAmount: 0,
        cardAmount: 0,
        paypayAmount: 0,
      );
    }
    return DailyPaymentSummaryModel.fromMap(rows.first);
  }
}
