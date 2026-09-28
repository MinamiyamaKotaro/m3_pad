import '../../../../core/errors/validation_exception.dart';
import '../../../../core/utils/id_generator.dart';
import '../entities/enums/enums.dart';
import '../entities/header.dart';
import '../entities/header_price.dart';
import '../repositories/header_price_repository.dart';
import '../repositories/header_repository.dart';
import '../repositories/header_type_repository.dart';
import '../repositories/sheet_template_repository.dart';

/// 伝票フォーマットに列（[Header]）を1件追加するユースケース（FR-1）。
///
/// 価格対象の列の場合は初期単価（[HeaderPrice]）も併せて登録する。
class AddHeaderUsecase {
  /// [AddHeaderUsecase] を生成する。
  const AddHeaderUsecase({
    required final SheetTemplateRepository templateRepository,
    required final HeaderTypeRepository headerTypeRepository,
    required final HeaderRepository headerRepository,
    required final HeaderPriceRepository headerPriceRepository,
    required final IdGenerator idGenerator,
  })  : _templateRepository = templateRepository,
        _headerTypeRepository = headerTypeRepository,
        _headerRepository = headerRepository,
        _headerPriceRepository = headerPriceRepository,
        _idGenerator = idGenerator;

  final SheetTemplateRepository _templateRepository;
  final HeaderTypeRepository _headerTypeRepository;
  final HeaderRepository _headerRepository;
  final HeaderPriceRepository _headerPriceRepository;
  final IdGenerator _idGenerator;

  /// 指定した伝票フォーマットに列を追加する。
  ///
  /// 価格対象の列（[isPriced]=true）の場合は [initialPrice]・
  /// [effectiveFrom] も同時に登録する。
  Future<Header> call({
    required final String sheetTemplateId,
    required final String name,
    required final int typeId,
    required final bool isPriced,
    final int? initialPrice,
    final DateTime? effectiveFrom,
  }) async {
    await _templateRepository.findById(sheetTemplateId);
    await _headerTypeRepository.findById(typeId);

    if (isPriced && (initialPrice == null || effectiveFrom == null)) {
      throw const ValidationException(
        reason: 'isPriced=trueの列にはinitialPriceとeffectiveFromが必須です',
      );
    }

    final List<Header> existingHeaders =
        await _headerRepository.findByTemplateId(sheetTemplateId);
    final int displayOrder = existingHeaders.isEmpty
        ? 1
        : existingHeaders
                .map((final Header header) => header.displayOrder)
                .reduce((final int a, final int b) => a > b ? a : b) +
            1;

    final String columnId = _idGenerator.generate();
    final DateTime now = DateTime.now();
    final Header header = Header(
      columnId: columnId,
      sheetTemplateId: sheetTemplateId,
      typeId: typeId,
      name: name,
      displayOrder: displayOrder,
      isPriced: isPriced,
      status: RecordStatus.active,
      createdAt: now,
      updatedAt: now,
    );
    await _headerRepository.insert(header);

    if (isPriced) {
      final String priceId = _idGenerator.generate();
      final HeaderPrice headerPrice = HeaderPrice(
        priceId: priceId,
        columnId: columnId,
        price: initialPrice!,
        effectiveFrom: effectiveFrom!,
        createdAt: now,
        updatedAt: now,
      );
      await _headerPriceRepository.insert(headerPrice);
    }

    return header;
  }
}
