import '../../domain/entities/daily_payment_summary.dart';
import '../../domain/repositories/daily_payment_summary_repository.dart';
import '../datasources/daily_payment_summary_local_datasource.dart';

/// [DailyPaymentSummaryRepository]（domain層インターフェース）の実装
/// クラス。[DailyPaymentSummaryLocalDataSource]へ処理を委譲する。
class DailyPaymentSummaryRepositoryImpl
    implements DailyPaymentSummaryRepository {
  /// [DailyPaymentSummaryRepositoryImpl] を生成する。
  const DailyPaymentSummaryRepositoryImpl(this._dataSource);

  final DailyPaymentSummaryLocalDataSource _dataSource;

  @override
  Future<DailyPaymentSummary> getByInstanceId(
    final String sheetInstanceId,
    final DateTime businessDate,
  ) async {
    final DailyPaymentSummary result = await _dataSource.getByInstanceId(
      sheetInstanceId,
      businessDate,
    );
    return result;
  }
}
