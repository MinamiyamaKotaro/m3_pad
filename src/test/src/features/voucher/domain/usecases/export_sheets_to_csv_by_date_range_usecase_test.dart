import 'package:flutter_test/flutter_test.dart';
import 'package:m3_pad/src/core/errors/validation_exception.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/customer.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/enums/enums.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/header.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/sheet_cell.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/sheet_instance.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/sheet_row.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/staff.dart';
import 'package:m3_pad/src/features/voucher/domain/repositories/customer_repository.dart';
import 'package:m3_pad/src/features/voucher/domain/repositories/header_price_repository.dart';
import 'package:m3_pad/src/features/voucher/domain/repositories/header_repository.dart';
import 'package:m3_pad/src/features/voucher/domain/repositories/sheet_cell_repository.dart';
import 'package:m3_pad/src/features/voucher/domain/repositories/sheet_instance_repository.dart';
import 'package:m3_pad/src/features/voucher/domain/repositories/sheet_row_repository.dart';
import 'package:m3_pad/src/features/voucher/domain/repositories/staff_repository.dart';
import 'package:m3_pad/src/features/voucher/domain/usecases/export_sheets_to_csv_by_date_range_usecase.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'export_sheets_to_csv_by_date_range_usecase_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<SheetInstanceRepository>(),
  MockSpec<HeaderRepository>(),
  MockSpec<SheetRowRepository>(),
  MockSpec<SheetCellRepository>(),
  MockSpec<CustomerRepository>(),
  MockSpec<StaffRepository>(),
  MockSpec<HeaderPriceRepository>(),
])
void main() {
  group('ExportSheetsToCsvByDateRangeUsecase', () {
    late MockSheetInstanceRepository instanceRepository;
    late MockHeaderRepository headerRepository;
    late MockSheetRowRepository rowRepository;
    late MockSheetCellRepository cellRepository;
    late MockCustomerRepository customerRepository;
    late MockStaffRepository staffRepository;
    late MockHeaderPriceRepository headerPriceRepository;
    late ExportSheetsToCsvByDateRangeUsecase usecase;

    final DateTime day1 = DateTime(2026, 9);
    final DateTime day2 = DateTime(2026, 9, 2);
    final SheetInstance instance1 = SheetInstance(
      sheetInstanceId: 'instance-1',
      sheetTemplateId: 'template-1',
      businessDate: day1,
      status: RecordStatus.active,
      createdAt: day1,
      updatedAt: day1,
    );
    final SheetInstance instance2 = SheetInstance(
      sheetInstanceId: 'instance-2',
      sheetTemplateId: 'template-1',
      businessDate: day2,
      status: RecordStatus.active,
      createdAt: day2,
      updatedAt: day2,
    );
    final Header chargeHeader = Header(
      columnId: 'col-charge',
      sheetTemplateId: 'template-1',
      typeId: 1,
      name: 'チャージ',
      displayOrder: 1,
      isPriced: true,
      status: RecordStatus.active,
      createdAt: day1,
      updatedAt: day1,
    );
    final SheetRow row1 = SheetRow(
      rowId: 'row-1',
      sheetInstanceId: 'instance-1',
      rowOrder: 1,
      totalAmount: 400,
      status: RecordStatus.active,
      createdAt: day1,
      updatedAt: day1,
    );
    final SheetRow row2 = SheetRow(
      rowId: 'row-2',
      sheetInstanceId: 'instance-2',
      rowOrder: 1,
      totalAmount: 800,
      status: RecordStatus.active,
      createdAt: day2,
      updatedAt: day2,
    );

    const String header = '営業日,お名前,チャージ,合計金額,担当';

    setUp(() {
      instanceRepository = MockSheetInstanceRepository();
      headerRepository = MockHeaderRepository();
      rowRepository = MockSheetRowRepository();
      cellRepository = MockSheetCellRepository();
      customerRepository = MockCustomerRepository();
      staffRepository = MockStaffRepository();
      headerPriceRepository = MockHeaderPriceRepository();
      usecase = ExportSheetsToCsvByDateRangeUsecase(
        instanceRepository: instanceRepository,
        headerRepository: headerRepository,
        rowRepository: rowRepository,
        cellRepository: cellRepository,
        customerRepository: customerRepository,
        staffRepository: staffRepository,
        headerPriceRepository: headerPriceRepository,
      );

      when(headerRepository.findByTemplateId('template-1')).thenAnswer(
        (final _) async => <Header>[chargeHeader],
      );
      when(staffRepository.findAllActive())
          .thenAnswer((final _) async => <Staff>[]);
    });

    test(
      'concatenates rows from every instance in the range into one CSV',
      () async {
        when(
          instanceRepository.findByTemplateIdAndDateRange(
            'template-1',
            day1,
            day2,
          ),
        ).thenAnswer((final _) async => <SheetInstance>[instance1, instance2]);
        when(
          rowRepository.findByInstanceIds(<String>['instance-1', 'instance-2']),
        ).thenAnswer((final _) async => <SheetRow>[row1, row2]);
        when(customerRepository.findByIds(<String>[]))
            .thenAnswer((final _) async => <Customer>[]);
        when(cellRepository.findByRowIds(<String>['row-1', 'row-2']))
            .thenAnswer(
          (final _) async => <SheetCell>[
            SheetCell(
              cellId: 'cell-1',
              rowId: 'row-1',
              columnId: 'col-charge',
              quantity: 1,
              unitPriceApplied: 400,
              amount: 400,
              createdAt: day1,
              updatedAt: day1,
            ),
            SheetCell(
              cellId: 'cell-2',
              rowId: 'row-2',
              columnId: 'col-charge',
              quantity: 2,
              unitPriceApplied: 400,
              amount: 800,
              createdAt: day2,
              updatedAt: day2,
            ),
          ],
        );

        final String csv = await usecase(
          sheetTemplateId: 'template-1',
          from: day1,
          to: day2,
        );

        expect(
          csv,
          '$header\n'
          '2026-09-01,,400,400,\n'
          '2026-09-02,,800,800,',
        );
      },
    );

    test(
      'throws ValidationException when the start date is after the end '
      'date',
      () {
        expect(
          () => usecase(
            sheetTemplateId: 'template-1',
            from: day2,
            to: day1,
          ),
          throwsA(isA<ValidationException>()),
        );
      },
    );

    test(
      'throws ValidationException when no sheets exist in the range',
      () {
        when(
          instanceRepository.findByTemplateIdAndDateRange(
            'template-1',
            day1,
            day2,
          ),
        ).thenAnswer((final _) async => <SheetInstance>[]);

        expect(
          () => usecase(sheetTemplateId: 'template-1', from: day1, to: day2),
          throwsA(isA<ValidationException>()),
        );
      },
    );
  });
}
