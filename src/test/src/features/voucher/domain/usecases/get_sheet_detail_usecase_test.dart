import 'package:flutter_test/flutter_test.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/customer.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/enums/enums.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/sheet_detail.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/sheet_instance.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/sheet_row.dart';
import 'package:m3_pad/src/features/voucher/domain/repositories/customer_repository.dart';
import 'package:m3_pad/src/features/voucher/domain/repositories/daily_payment_summary_repository.dart';
import 'package:m3_pad/src/features/voucher/domain/repositories/header_price_repository.dart';
import 'package:m3_pad/src/features/voucher/domain/repositories/header_repository.dart';
import 'package:m3_pad/src/features/voucher/domain/repositories/sheet_cell_repository.dart';
import 'package:m3_pad/src/features/voucher/domain/repositories/sheet_instance_repository.dart';
import 'package:m3_pad/src/features/voucher/domain/repositories/sheet_row_repository.dart';
import 'package:m3_pad/src/features/voucher/domain/repositories/staff_repository.dart';
import 'package:m3_pad/src/features/voucher/domain/repositories/staff_shift_repository.dart';
import 'package:m3_pad/src/features/voucher/domain/usecases/get_sheet_detail_usecase.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_sheet_detail_usecase_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<SheetInstanceRepository>(),
  MockSpec<HeaderRepository>(),
  MockSpec<SheetRowRepository>(),
  MockSpec<SheetCellRepository>(),
  MockSpec<StaffShiftRepository>(),
  MockSpec<DailyPaymentSummaryRepository>(),
  MockSpec<StaffRepository>(),
  MockSpec<CustomerRepository>(),
  MockSpec<HeaderPriceRepository>(),
])
void main() {
  group('GetSheetDetailUsecase', () {
    late MockSheetInstanceRepository instanceRepository;
    late MockSheetRowRepository rowRepository;
    late MockCustomerRepository customerRepository;
    late GetSheetDetailUsecase usecase;

    final DateTime businessDate = DateTime(2026, 10, 3);
    final SheetInstance instance = SheetInstance(
      sheetInstanceId: 'instance-1',
      sheetTemplateId: 'template-1',
      businessDate: businessDate,
      status: RecordStatus.active,
      createdAt: businessDate,
      updatedAt: businessDate,
    );

    SheetRow row(final String rowId, final String? customerId) => SheetRow(
          rowId: rowId,
          sheetInstanceId: 'instance-1',
          customerId: customerId,
          rowOrder: 1,
          totalAmount: 0,
          status: RecordStatus.active,
          createdAt: businessDate,
          updatedAt: businessDate,
        );

    Customer customer(final String customerId) => Customer(
          customerId: customerId,
          name: customerId,
          gender: Gender.none,
          status: RecordStatus.active,
          createdAt: businessDate,
          updatedAt: businessDate,
        );

    setUp(() {
      instanceRepository = MockSheetInstanceRepository();
      rowRepository = MockSheetRowRepository();
      customerRepository = MockCustomerRepository();
      usecase = GetSheetDetailUsecase(
        instanceRepository: instanceRepository,
        headerRepository: MockHeaderRepository(),
        rowRepository: rowRepository,
        cellRepository: MockSheetCellRepository(),
        staffShiftRepository: MockStaffShiftRepository(),
        dailyPaymentSummaryRepository: MockDailyPaymentSummaryRepository(),
        staffRepository: MockStaffRepository(),
        customerRepository: customerRepository,
        headerPriceRepository: MockHeaderPriceRepository(),
      );
      when(instanceRepository.findById('instance-1'))
          .thenAnswer((final _) async => instance);
    });

    test(
      'marks customers without visits before the business date as new',
      () async {
        when(rowRepository.findByInstanceId('instance-1')).thenAnswer(
          (final _) async => <SheetRow>[
            row('row-1', 'cust-new'),
            row('row-2', 'cust-regular'),
            row('row-3', null),
          ],
        );
        when(
          customerRepository.findByIds(<String>['cust-new', 'cust-regular']),
        ).thenAnswer(
          (final _) async => <Customer>[
            customer('cust-new'),
            customer('cust-regular'),
          ],
        );
        when(
          rowRepository.findCustomerIdsVisitedBefore(
            <String>['cust-new', 'cust-regular'],
            businessDate,
          ),
        ).thenAnswer((final _) async => <String>['cust-regular']);

        final SheetDetail detail = await usecase('instance-1');

        expect(detail.newCustomerIds, <String>{'cust-new'});
      },
    );

    test('returns no new customers when no rows have a customer', () async {
      when(rowRepository.findByInstanceId('instance-1'))
          .thenAnswer((final _) async => <SheetRow>[row('row-1', null)]);
      when(customerRepository.findByIds(<String>[]))
          .thenAnswer((final _) async => <Customer>[]);
      when(rowRepository.findCustomerIdsVisitedBefore(<String>[], businessDate))
          .thenAnswer((final _) async => <String>[]);

      final SheetDetail detail = await usecase('instance-1');

      expect(detail.newCustomerIds, isEmpty);
    });
  });
}
