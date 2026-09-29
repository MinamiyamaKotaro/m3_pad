import 'package:flutter_test/flutter_test.dart';
import 'package:m3_pad/src/core/errors/validation_exception.dart';
import 'package:m3_pad/src/core/utils/id_generator.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/enums/enums.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/header.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/header_price.dart';
import 'package:m3_pad/src/features/voucher/domain/repositories/header_price_repository.dart';
import 'package:m3_pad/src/features/voucher/domain/repositories/header_repository.dart';
import 'package:m3_pad/src/features/voucher/domain/usecases/update_header_usecase.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'update_header_usecase_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<HeaderRepository>(),
  MockSpec<HeaderPriceRepository>(),
  MockSpec<IdGenerator>(),
])
void main() {
  group('UpdateHeaderUsecase', () {
    late MockHeaderRepository headerRepository;
    late MockHeaderPriceRepository headerPriceRepository;
    late MockIdGenerator idGenerator;
    late UpdateHeaderUsecase usecase;

    final DateTime now = DateTime(2026, 9, 29);
    final Header pricedHeader = Header(
      columnId: 'col-charge',
      sheetTemplateId: 'template-1',
      typeId: 1,
      name: 'チャージ',
      displayOrder: 1,
      isPriced: true,
      category: HeaderCategory.drink,
      status: RecordStatus.active,
      createdAt: now,
      updatedAt: now,
    );

    setUp(() {
      headerRepository = MockHeaderRepository();
      headerPriceRepository = MockHeaderPriceRepository();
      idGenerator = MockIdGenerator();
      usecase = UpdateHeaderUsecase(
        headerRepository: headerRepository,
        headerPriceRepository: headerPriceRepository,
        idGenerator: idGenerator,
      );

      when(
        headerRepository.findById('col-charge'),
      ).thenAnswer((final _) async => pricedHeader);
    });

    test('updates the name, category, and visibility', () async {
      final Header updated = await usecase(
        columnId: 'col-charge',
        name: 'お茶ハイ',
        category: HeaderCategory.food,
        isVisible: false,
      );

      expect(updated.name, 'お茶ハイ');
      expect(updated.category, HeaderCategory.food);
      expect(updated.isVisible, false);
      verify(headerRepository.update(updated)).called(1);
      verifyNever(headerPriceRepository.closeCurrentPrice(any, any));
      verifyNever(headerPriceRepository.insert(any));
    });

    test('throws ValidationException when the name is blank', () {
      expect(
        () => usecase(
          columnId: 'col-charge',
          name: '  ',
          category: HeaderCategory.drink,
          isVisible: true,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test(
      'closes the current price and inserts a new one when the price '
      'changes',
      () async {
        final HeaderPrice currentPrice = HeaderPrice(
          priceId: 'price-1',
          columnId: 'col-charge',
          price: 400,
          effectiveFrom: DateTime(2026),
          createdAt: now,
          updatedAt: now,
        );
        when(
          headerPriceRepository.findCurrentPrice('col-charge', any),
        ).thenAnswer((final _) async => currentPrice);
        when(idGenerator.generate()).thenReturn('price-2');

        final DateTime effectiveFrom = DateTime(2026, 10);
        await usecase(
          columnId: 'col-charge',
          name: 'チャージ',
          category: HeaderCategory.drink,
          isVisible: true,
          newPrice: 500,
          priceEffectiveFrom: effectiveFrom,
        );

        verify(
          headerPriceRepository.closeCurrentPrice('price-1', effectiveFrom),
        ).called(1);
        final HeaderPrice inserted =
            verify(headerPriceRepository.insert(captureAny)).captured.single
                as HeaderPrice;
        expect(inserted.price, 500);
        expect(inserted.columnId, 'col-charge');
        expect(inserted.effectiveFrom, effectiveFrom);
      },
    );

    test('does not revise the price when it is unchanged', () async {
      final HeaderPrice currentPrice = HeaderPrice(
        priceId: 'price-1',
        columnId: 'col-charge',
        price: 400,
        effectiveFrom: DateTime(2026),
        createdAt: now,
        updatedAt: now,
      );
      when(
        headerPriceRepository.findCurrentPrice('col-charge', any),
      ).thenAnswer((final _) async => currentPrice);

      await usecase(
        columnId: 'col-charge',
        name: 'チャージ',
        category: HeaderCategory.drink,
        isVisible: true,
        newPrice: 400,
        priceEffectiveFrom: DateTime(2026, 10),
      );

      verifyNever(headerPriceRepository.closeCurrentPrice(any, any));
      verifyNever(headerPriceRepository.insert(any));
    });

    test(
      'throws ValidationException when changing the price of a '
      'non-priced column',
      () {
        final Header memoHeader = Header(
          columnId: 'col-memo',
          sheetTemplateId: 'template-1',
          typeId: 2,
          name: 'MEMO',
          displayOrder: 2,
          isPriced: false,
          status: RecordStatus.active,
          createdAt: now,
          updatedAt: now,
        );
        when(
          headerRepository.findById('col-memo'),
        ).thenAnswer((final _) async => memoHeader);

        expect(
          () => usecase(
            columnId: 'col-memo',
            name: 'MEMO',
            category: HeaderCategory.none,
            isVisible: true,
            newPrice: 100,
            priceEffectiveFrom: DateTime(2026, 10),
          ),
          throwsA(isA<ValidationException>()),
        );
      },
    );
  });
}
