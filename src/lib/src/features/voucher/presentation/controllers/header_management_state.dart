import '../../domain/entities/header.dart';

/// ヘッダー管理画面（`MMM_003_VOUCHER`）のライフサイクル状態。
enum HeaderManagementStatus {
  /// 画面生成直後、まだ読み込みを開始していない状態。
  initial,

  /// データ取得中（インジケータ表示用）。
  loading,

  /// データが正常に取得でき、画面描画が可能な状態。
  success,

  /// 取得に失敗した異常系（エラーメッセージ・再試行ボタン表示用）。
  error,
}

/// ヘッダー管理画面（`MMM_003_VOUCHER`）のUI状態（UiState）を表すクラス。
///
/// HeaderManagementNotifierが保持・更新し、HeaderManagementPageが監視する。
class HeaderManagementState {
  /// [HeaderManagementState] を生成する。
  const HeaderManagementState({
    this.status = HeaderManagementStatus.initial,
    this.headers = const <Header>[],
    this.unitPricesByColumnId = const <String, int>{},
    this.errorMessage,
  });

  /// 画面状態。
  final HeaderManagementStatus status;

  /// 価格対象の列一覧（「お名前」「MEMO」「合計金額」「担当」を除く）。
  /// `displayOrder`昇順。
  final List<Header> headers;

  /// 列ID別の現在の適用単価Map。
  final Map<String, int> unitPricesByColumnId;

  /// エラーメッセージ。`status`が`error`の場合のみ非`null`。
  final String? errorMessage;

  /// 一部のプロパティのみを変更した新しい [HeaderManagementState] を生成
  /// する。
  HeaderManagementState copyWith({
    final HeaderManagementStatus? status,
    final List<Header>? headers,
    final Map<String, int>? unitPricesByColumnId,
    final String? errorMessage,
  }) =>
      HeaderManagementState(
        status: status ?? this.status,
        headers: headers ?? this.headers,
        unitPricesByColumnId: unitPricesByColumnId ?? this.unitPricesByColumnId,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}
