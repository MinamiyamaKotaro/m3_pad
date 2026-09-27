import 'package:flutter_test/flutter_test.dart';
import 'package:m3_pad/src/core/errors/validation_exception.dart';
import 'package:m3_pad/src/core/utils/id_generator.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/enums/enums.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/header.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/header_price.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/sheet_cell.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/sheet_instance.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/sheet_row.dart';
import 'package:m3_pad/src/features/voucher/domain/repositories/header_price_repository.dart';
import 'package:m3_pad/src/features/voucher/domain/repositories/header_repository.dart';
import 'package:m3_pad/src/features/voucher/domain/repositories/sheet_cell_repository.dart';
import 'package:m3_pad/src/features/voucher/domain/repositories/sheet_instance_repository.dart';
import 'package:m3_pad/src/features/voucher/domain/repositories/sheet_row_repository.dart';
import 'package:m3_pad/src/features/voucher/domain/usecases/input_cell_usecase.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'input_cell_usecase_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<SheetRowRepository>(),
  MockSpec<SheetInstanceRepository>(),
  MockSpec<HeaderRepository>(),
  MockSpec<HeaderPriceRepository>(),
  MockSpec<SheetCellRepository>(),
  MockSpec<IdGenerator>(),
])
void main() {
  group('InputCellUsecase', () {
    late MockSheetRowRepository rowRepository;
    late MockSheetInstanceRepository instanceRepository;
    late MockHeaderRepository headerRepository;
    late MockHeaderPriceRepository headerPriceRepository;
    late MockSheetCellRepository cellRepository;
    late MockIdGenerator idGenerator;
    late InputCellUsecase usecase;

    final DateTime now = DateTime(2026, 9, 28);
    final SheetRow row = SheetRow(
      rowId: 'row-1',
      sheetInstanceId: 'instance-1',
      rowOrder: 1,
      totalAmount: 0,
      status: RecordStatus.active,
      createdAt: now,
      updatedAt: now,
    );
    final SheetInstance instance = SheetInstance(
      sheetInstanceId: 'instance-1',
      sheetTemplateId: 'template-1',
      businessDate: now,
      status: RecordStatus.active,
      createdAt: now,
      updatedAt: now,
    );

    setUp(() {
      rowRepository = MockSheetRowRepository();
      instanceRepository = MockSheetInstanceRepository();
      headerRepository = MockHeaderRepository();
      headerPriceRepository = MockHeaderPriceRepository();
      cellRepository = MockSheetCellRepository();
      idGenerator = MockIdGenerator();
      usecase = InputCellUsecase(
        rowRepository: rowRepository,
        instanceRepository: instanceRepository,
        headerRepository: headerRepository,
        headerPriceRepository: headerPriceRepository,
        cellRepository: cellRepository,
        idGenerator: idGenerator,
      );

      when(rowRepository.findById('row-1')).thenAnswer((final _) async => row);
      when(instanceRepository.findById('instance-1'))
          .thenAnswer((final _) async => instance);
    });

    Header pricedHeader({required final bool isPriced}) => Header(
          columnId: 'col-charge',
          sheetTemplateId: 'template-1',
          typeId: 1,
          name: 'チャージ',
          displayOrder: 1,
          isPriced: isPriced,
          status: RecordStatus.active,
          createdAt: now,
          updatedAt: now,
        );

    test(
      'computes amount as quantity times the current unit price snapshot',
      () async {
        when(headerRepository.findById('col-charge')).thenAnswer(
          (final _) async => pricedHeader(isPriced: true),
        );
        when(cellRepository.findByRowAndColumn('row-1', 'col-charge'))
            .thenAnswer((final _) async => null);
        when(
          headerPriceRepository.findCurrentPrice('col-charge', now),
        ).thenAnswer(
          (final _) async => HeaderPrice(
            priceId: 'price-1',
            columnId: 'col-charge',
            price: 400,
            effectiveFrom: now,
            createdAt: now,
            updatedAt: now,
          ),
        );
        when(idGenerator.generate()).thenReturn('cell-1');

        final SheetCell cell = await usecase(
          rowId: 'row-1',
          columnId: 'col-charge',
          quantity: 3,
        );

        expect(cell.quantity, 3);
        expect(cell.unitPriceApplied, 400);
        expect(cell.amount, 1200);
        verify(cellRepository.insert(cell)).called(1);
      },
    );

    test(
      'stores a zero quantity without dividing by it to recover the price',
      () async {
        when(headerRepository.findById('col-charge')).thenAnswer(
          (final _) async => pricedHeader(isPriced: true),
        );
        when(cellRepository.findByRowAndColumn('row-1', 'col-charge'))
            .thenAnswer((final _) async => null);
        when(
          headerPriceRepository.findCurrentPrice('col-charge', now),
        ).thenAnswer(
          (final _) async => HeaderPrice(
            priceId: 'price-1',
            columnId: 'col-charge',
            price: 400,
            effectiveFrom: now,
            createdAt: now,
            updatedAt: now,
          ),
        );
        when(idGenerator.generate()).thenReturn('cell-1');

        final SheetCell cell = await usecase(
          rowId: 'row-1',
          columnId: 'col-charge',
          quantity: 0,
        );

        expect(cell.amount, 0);
        expect(cell.unitPriceApplied, 400);
      },
    );

    test('throws ValidationException when a priced column has no quantity', () {
      when(headerRepository.findById('col-charge')).thenAnswer(
        (final _) async => pricedHeader(isPriced: true),
      );
      when(cellRepository.findByRowAndColumn('row-1', 'col-charge'))
          .thenAnswer((final _) async => null);

      expect(
        () => usecase(rowId: 'row-1', columnId: 'col-charge'),
        throwsA(isA<ValidationException>()),
      );
    });

    test(
      'throws ValidationException when a non-priced column has no content',
      () {
        when(headerRepository.findById('col-charge')).thenAnswer(
          (final _) async => pricedHeader(isPriced: false),
        );
        when(cellRepository.findByRowAndColumn('row-1', 'col-charge'))
            .thenAnswer((final _) async => null);

        expect(
          () => usecase(rowId: 'row-1', columnId: 'col-charge'),
          throwsA(isA<ValidationException>()),
        );
      },
    );

    test('updates an existing cell instead of inserting a new one', () async {
      final SheetCell existing = SheetCell(
        cellId: 'cell-1',
        rowId: 'row-1',
        columnId: 'col-memo',
        content: '旧メモ',
        createdAt: now,
        updatedAt: now,
      );
      when(headerRepository.findById('col-memo')).thenAnswer(
        (final _) async => pricedHeader(isPriced: false),
      );
      when(cellRepository.findByRowAndColumn('row-1', 'col-memo'))
          .thenAnswer((final _) async => existing);

      final SheetCell cell = await usecase(
        rowId: 'row-1',
        columnId: 'col-memo',
        content: '新メモ',
      );

      expect(cell.cellId, 'cell-1');
      expect(cell.content, '新メモ');
      verify(cellRepository.update(cell)).called(1);
      verifyNever(cellRepository.insert(any));
    });
  });
}
