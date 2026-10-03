import '../../../../core/errors/validation_exception.dart';
import '../../../../core/utils/id_generator.dart';
import '../entities/enums/enums.dart';
import '../entities/header.dart';
import '../entities/header_price.dart';
import '../repositories/header_price_repository.dart';
import '../repositories/header_repository.dart';

/// 既存の列（[Header]）の項目名・カテゴリー・表示/非表示・単価を更新する
/// ユースケース（FR-6）。
///
/// 単価を変更する場合は、既存の[HeaderPrice]の適用終了日を確定させた上で
/// 新しい[HeaderPrice]を追加する（価格改定履歴として保持し、過去の伝票の
/// 単価は変えない）。
class UpdateHeaderUsecase {
  /// [UpdateHeaderUsecase] を生成する。
  const UpdateHeaderUsecase({
    required final HeaderRepository headerRepository,
    required final HeaderPriceRepository headerPriceRepository,
    required final IdGenerator idGenerator,
  })  : _headerRepository = headerRepository,
        _headerPriceRepository = headerPriceRepository,
        _idGenerator = idGenerator;

  final HeaderRepository _headerRepository;
  final HeaderPriceRepository _headerPriceRepository;
  final IdGenerator _idGenerator;

  /// 指定した [columnId] の列を更新する。
  ///
  /// 価格対象の列（[Header.isPriced]=true）の単価を変更する場合は
  /// [newPrice]・[priceEffectiveFrom] を指定する。
  Future<Header> call({
    required final String columnId,
    required final String name,
    required final HeaderCategory category,
    required final bool isVisible,
    final int? newPrice,
    final DateTime? priceEffectiveFrom,
  }) async {
    final Header current = await _headerRepository.findById(columnId);

    if (name.trim().isEmpty) {
      throw const ValidationException(reason: '項目名は必須です');
    }

    if (newPrice != null) {
      if (!current.isPriced) {
        throw const ValidationException(
          reason: '価格対象でない列（isPriced=false）には価格を設定できません',
        );
      }
      if (priceEffectiveFrom == null) {
        throw const ValidationException(
          reason: '価格を変更する場合はpriceEffectiveFromが必須です',
        );
      }
      await _revisePriceIfChanged(columnId, newPrice, priceEffectiveFrom);
    }

    final DateTime now = DateTime.now();
    final Header updated = Header(
      columnId: current.columnId,
      sheetTemplateId: current.sheetTemplateId,
      typeId: current.typeId,
      name: name,
      displayOrder: current.displayOrder,
      isPriced: current.isPriced,
      category: category,
      isVisible: isVisible,
      status: current.status,
      createdAt: current.createdAt,
      updatedAt: now,
    );
    await _headerRepository.update(updated);
    return updated;
  }

  Future<void> _revisePriceIfChanged(
    final String columnId,
    final int newPrice,
    final DateTime effectiveFrom,
  ) async {
    final HeaderPrice currentPrice =
        await _headerPriceRepository.findCurrentPrice(columnId, effectiveFrom);
    if (currentPrice.price == newPrice) {
      return;
    }
    await _headerPriceRepository.closeCurrentPrice(
      currentPrice.priceId,
      effectiveFrom,
    );
    final String priceId = _idGenerator.generate();
    final DateTime now = DateTime.now();
    await _headerPriceRepository.insert(
      HeaderPrice(
        priceId: priceId,
        columnId: columnId,
        price: newPrice,
        effectiveFrom: effectiveFrom,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }
}
