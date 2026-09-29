import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/record_not_found_exception.dart';
import '../../domain/entities/enums/enums.dart';
import '../../domain/entities/header.dart';
import '../../domain/entities/header_price.dart';
import '../../domain/entities/header_type.dart';
import 'header_management_state.dart';
import 'voucher_providers.dart';

/// ヘッダー管理画面（`MMM_003_VOUCHER`）の状態（[HeaderManagementState]）を
/// 管理するRiverpod Notifier。
///
/// 価格対象の列一覧の読込・追加・更新（項目名・カテゴリー・単価・表示/
/// 非表示、FR-6）を担う。
class HeaderManagementNotifier extends Notifier<HeaderManagementState> {
  String? _sheetTemplateId;

  @override
  HeaderManagementState build() => const HeaderManagementState();

  /// 画面生成時に呼び出され、指定した伝票フォーマットの価格対象の列一覧
  /// （「お名前」「MEMO」「合計金額」「担当」を除く）と現在の適用単価を
  /// 読み込む。
  Future<void> load(final String sheetTemplateId) async {
    _sheetTemplateId = sheetTemplateId;
    state = state.copyWith(status: HeaderManagementStatus.loading);
    try {
      final List<Header> allHeaders =
          await ref.read(headerRepositoryProvider).findByTemplateId(
                sheetTemplateId,
              );
      final List<Header> headers =
          allHeaders.where((final Header header) => header.isPriced).toList();

      final DateTime now = DateTime.now();
      final Map<String, int> unitPricesByColumnId = <String, int>{};
      for (final Header header in headers) {
        try {
          final HeaderPrice currentPrice = await ref
              .read(headerPriceRepositoryProvider)
              .findCurrentPrice(header.columnId, now);
          unitPricesByColumnId[header.columnId] = currentPrice.price;
        } on RecordNotFoundException {
          // 単価未登録の列は表示上「単価なし」として扱う。
        }
      }

      state = state.copyWith(
        status: HeaderManagementStatus.success,
        headers: headers,
        unitPricesByColumnId: unitPricesByColumnId,
      );
    } on Exception catch (error) {
      state = state.copyWith(
        status: HeaderManagementStatus.error,
        errorMessage: error.toString(),
      );
    }
  }

  /// 価格対象の列を1件追加する。成功時は`null`、失敗時はエラーメッセージを
  /// 返す。
  Future<String?> addHeader({
    required final String name,
    required final HeaderCategory category,
    required final int price,
    required final bool isVisible,
  }) =>
      _runAndReload(() async {
        final List<HeaderType> headerTypes =
            await ref.read(headerTypeRepositoryProvider).findAll();
        final int decimalTypeId = headerTypes
            .firstWhere(
              (final HeaderType type) =>
                  type.typeName == ColumnValueType.decimal,
            )
            .typeId;
        await ref.read(addHeaderUsecaseProvider).call(
              sheetTemplateId: _requireTemplateId(),
              name: name,
              typeId: decimalTypeId,
              isPriced: true,
              initialPrice: price,
              effectiveFrom: DateTime.now(),
              category: category,
              isVisible: isVisible,
            );
      });

  /// 列の項目名・カテゴリー・表示/非表示を更新する。[newPrice]を指定した
  /// 場合は単価も改定する（適用開始日は更新実行時刻）。成功時は`null`、
  /// 失敗時はエラーメッセージを返す。
  Future<String?> updateHeader({
    required final String columnId,
    required final String name,
    required final HeaderCategory category,
    required final bool isVisible,
    final int? newPrice,
  }) =>
      _runAndReload(
        () => ref.read(updateHeaderUsecaseProvider).call(
              columnId: columnId,
              name: name,
              category: category,
              isVisible: isVisible,
              newPrice: newPrice,
              priceEffectiveFrom: newPrice == null ? null : DateTime.now(),
            ),
      );

  Future<String?> _runAndReload(final Future<void> Function() action) async {
    try {
      await action();
      await load(_requireTemplateId());
      return null;
    } on Exception catch (error) {
      return error.toString();
    }
  }

  String _requireTemplateId() {
    final String? id = _sheetTemplateId;
    if (id == null) {
      throw StateError('sheetTemplateId is not loaded yet');
    }
    return id;
  }
}

/// [HeaderManagementNotifier] を提供するプロバイダ。
final NotifierProvider<HeaderManagementNotifier, HeaderManagementState>
    headerManagementNotifierProvider =
    NotifierProvider<HeaderManagementNotifier, HeaderManagementState>(
  HeaderManagementNotifier.new,
);
