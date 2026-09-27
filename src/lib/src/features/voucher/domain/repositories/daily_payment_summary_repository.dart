import '../entities/daily_payment_summary.dart';

/// [DailyPaymentSummary] の取得の契約のみを定義する抽象クラス。
///
/// DBのビュー`v_daily_payment_summary`から読み取る。読み取り専用のため
/// 更新系メソッドは持たない。
// 他のRepositoryと同様、DI・モック差し替えのためあえてinterfaceとする。
// ignore: one_member_abstracts
abstract interface class DailyPaymentSummaryRepository {
  /// [sheetInstanceId] に対応する日次集計を1件取得する。
  ///
  /// 該当行が1件もない場合は、[businessDate] を用い金額項目をすべて0と
  /// した値を返す（例外は送出しない）。
  Future<DailyPaymentSummary> getByInstanceId(
    final String sheetInstanceId,
    final DateTime businessDate,
  );
}
