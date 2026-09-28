import '../../../../core/utils/id_generator.dart';
import '../entities/enums/enums.dart';
import '../entities/sheet_template.dart';
import '../repositories/sheet_template_repository.dart';

/// 新しい伝票フォーマット（[SheetTemplate]）を作成するユースケース（FR-1）。
class CreateTemplateUsecase {
  /// [CreateTemplateUsecase] を生成する。
  const CreateTemplateUsecase({
    required final SheetTemplateRepository templateRepository,
    required final IdGenerator idGenerator,
  })  : _templateRepository = templateRepository,
        _idGenerator = idGenerator;

  final SheetTemplateRepository _templateRepository;
  final IdGenerator _idGenerator;

  /// 指定した [name] で新しい [SheetTemplate] を作成し、永続化する。
  Future<SheetTemplate> call(final String name) async {
    final String sheetTemplateId = _idGenerator.generate();
    final DateTime now = DateTime.now();
    final SheetTemplate template = SheetTemplate(
      sheetTemplateId: sheetTemplateId,
      name: name,
      status: RecordStatus.active,
      createdAt: now,
      updatedAt: now,
    );
    await _templateRepository.insert(template);
    return template;
  }
}
