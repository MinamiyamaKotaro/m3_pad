import 'package:flutter_test/flutter_test.dart';
import 'package:m3_pad/src/core/utils/id_generator.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/enums/enums.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/sheet_template.dart';
import 'package:m3_pad/src/features/voucher/domain/repositories/sheet_template_repository.dart';
import 'package:m3_pad/src/features/voucher/domain/usecases/create_template_usecase.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'create_template_usecase_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<SheetTemplateRepository>(),
  MockSpec<IdGenerator>(),
])
void main() {
  group('CreateTemplateUsecase', () {
    late MockSheetTemplateRepository templateRepository;
    late MockIdGenerator idGenerator;
    late CreateTemplateUsecase usecase;

    setUp(() {
      templateRepository = MockSheetTemplateRepository();
      idGenerator = MockIdGenerator();
      usecase = CreateTemplateUsecase(
        templateRepository: templateRepository,
        idGenerator: idGenerator,
      );
    });

    test('creates and persists an active template with the given name',
        () async {
      when(idGenerator.generate()).thenReturn('template-1');

      final SheetTemplate template = await usecase('寿');

      expect(template.sheetTemplateId, 'template-1');
      expect(template.name, '寿');
      expect(template.status, RecordStatus.active);
      verify(templateRepository.insert(template)).called(1);
    });
  });
}
