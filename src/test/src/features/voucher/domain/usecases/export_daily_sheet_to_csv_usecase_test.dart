import 'package:flutter_test/flutter_test.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/customer.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/enums/enums.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/header.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/sheet_cell.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/sheet_instance.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/sheet_row.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/staff.dart';
import 'package:m3_pad/src/features/voucher/domain/repositories/customer_repository.dart';
import 'package:m3_pad/src/features/voucher/domain/repositories/header_repository.dart';
import 'package:m3_pad/src/features/voucher/domain/repositories/sheet_cell_repository.dart';
import 'package:m3_pad/src/features/voucher/domain/repositories/sheet_instance_repository.dart';
import 'package:m3_pad/src/features/voucher/domain/repositories/sheet_row_repository.dart';
import 'package:m3_pad/src/features/voucher/domain/repositories/staff_repository.dart';
import 'package:m3_pad/src/features/voucher/domain/usecases/export_daily_sheet_to_csv_usecase.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'export_daily_sheet_to_csv_usecase_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<SheetInstanceRepository>(),
  MockSpec<HeaderRepository>(),
  MockSpec<SheetRowRepository>(),
  MockSpec<SheetCellRepository>(),
  MockSpec<CustomerRepository>(),
  MockSpec<StaffRepository>(),
])
void main() {
  group('ExportDailySheetToCsvUsecase', () {
    late MockSheetInstanceRepository instanceRepository;
    late MockHeaderRepository headerRepository;
    late MockSheetRowRepository rowRepository;
    late MockSheetCellRepository cellRepository;
    late MockCustomerRepository customerRepository;
    late MockStaffRepository staffRepository;
    late ExportDailySheetToCsvUsecase usecase;

    final DateTime now = DateTime(2026, 9, 28);
    final SheetInstance instance = SheetInstance(
      sheetInstanceId: 'instance-1',
      sheetTemplateId: 'template-1',
      businessDate: now,
      status: RecordStatus.active,
      createdAt: now,
      updatedAt: now,
    );
    final Header chargeHeader = Header(
      columnId: 'col-charge',
      sheetTemplateId: 'template-1',
      typeId: 1,
      name: 'チャージ',
      displayOrder: 1,
      isPriced: true,
      status: RecordStatus.active,
      createdAt: now,
      updatedAt: now,
    );
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
    final SheetRow row = SheetRow(
      rowId: 'row-1',
      sheetInstanceId: 'instance-1',
      rowOrder: 1,
      totalAmount: 800,
      status: RecordStatus.active,
      createdAt: now,
      updatedAt: now,
    );

    const String header = '営業日,お名前,チャージ,MEMO,合計金額,担当';

    setUp(() {
      instanceRepository = MockSheetInstanceRepository();
      headerRepository = MockHeaderRepository();
      rowRepository = MockSheetRowRepository();
      cellRepository = MockSheetCellRepository();
      customerRepository = MockCustomerRepository();
      staffRepository = MockStaffRepository();
      usecase = ExportDailySheetToCsvUsecase(
        instanceRepository: instanceRepository,
        headerRepository: headerRepository,
        rowRepository: rowRepository,
        cellRepository: cellRepository,
        customerRepository: customerRepository,
        staffRepository: staffRepository,
      );

      when(instanceRepository.findById('instance-1'))
          .thenAnswer((final _) async => instance);
      when(headerRepository.findByTemplateId('template-1')).thenAnswer(
        (final _) async => <Header>[chargeHeader, memoHeader],
      );
      when(staffRepository.findAllActive())
          .thenAnswer((final _) async => <Staff>[]);
    });

    test('writes the header line followed by one line per row', () async {
      when(rowRepository.findByInstanceId('instance-1'))
          .thenAnswer((final _) async => <SheetRow>[row]);
      when(customerRepository.findByIds(<String>[]))
          .thenAnswer((final _) async => <Customer>[]);
      when(cellRepository.findByRowIds(<String>['row-1'])).thenAnswer(
        (final _) async => <SheetCell>[
          SheetCell(
            cellId: 'cell-1',
            rowId: 'row-1',
            columnId: 'col-charge',
            quantity: 2,
            unitPriceApplied: 400,
            amount: 800,
            createdAt: now,
            updatedAt: now,
          ),
          SheetCell(
            cellId: 'cell-2',
            rowId: 'row-1',
            columnId: 'col-memo',
            content: 'ご来店ありがとうございます',
            createdAt: now,
            updatedAt: now,
          ),
        ],
      );

      final String csv = await usecase('instance-1');

      expect(
        csv,
        '$header\n2026-09-28,,800,ご来店ありがとうございます,800,',
      );
    });

    test('renders an empty cell as an empty CSV field', () async {
      when(rowRepository.findByInstanceId('instance-1'))
          .thenAnswer((final _) async => <SheetRow>[row]);
      when(customerRepository.findByIds(<String>[]))
          .thenAnswer((final _) async => <Customer>[]);
      when(cellRepository.findByRowIds(<String>['row-1']))
          .thenAnswer((final _) async => <SheetCell>[]);

      final String csv = await usecase('instance-1');

      expect(csv, '$header\n2026-09-28,,,,800,');
    });

    test('resolves the linked customer name and staff name', () async {
      final SheetRow linkedRow = SheetRow(
        rowId: 'row-1',
        sheetInstanceId: 'instance-1',
        customerId: 'cust-1',
        staffId: 'staff-1',
        rowOrder: 1,
        totalAmount: 800,
        status: RecordStatus.active,
        createdAt: now,
        updatedAt: now,
      );
      when(rowRepository.findByInstanceId('instance-1'))
          .thenAnswer((final _) async => <SheetRow>[linkedRow]);
      when(customerRepository.findByIds(<String>['cust-1'])).thenAnswer(
        (final _) async => <Customer>[
          Customer(
            customerId: 'cust-1',
            name: '田中',
            gender: Gender.none,
            status: RecordStatus.active,
            createdAt: now,
            updatedAt: now,
          ),
        ],
      );
      when(staffRepository.findAllActive()).thenAnswer(
        (final _) async => <Staff>[
          Staff(
            staffId: 'staff-1',
            name: '佐藤',
            status: RecordStatus.active,
            createdAt: now,
            updatedAt: now,
          ),
        ],
      );
      when(cellRepository.findByRowIds(<String>['row-1']))
          .thenAnswer((final _) async => <SheetCell>[]);

      final String csv = await usecase('instance-1');

      expect(csv, '$header\n2026-09-28,田中,,,800,佐藤');
    });

    test('quotes a value that contains a comma, quote, or newline', () async {
      when(rowRepository.findByInstanceId('instance-1'))
          .thenAnswer((final _) async => <SheetRow>[row]);
      when(customerRepository.findByIds(<String>[]))
          .thenAnswer((final _) async => <Customer>[]);
      when(cellRepository.findByRowIds(<String>['row-1'])).thenAnswer(
        (final _) async => <SheetCell>[
          SheetCell(
            cellId: 'cell-2',
            rowId: 'row-1',
            columnId: 'col-memo',
            content: '田中様, "VIP"\n要注意',
            createdAt: now,
            updatedAt: now,
          ),
        ],
      );

      final String csv = await usecase('instance-1');

      expect(
        csv,
        '$header\n2026-09-28,,,"田中様, ""VIP""\n要注意",800,',
      );
    });
  });
}
