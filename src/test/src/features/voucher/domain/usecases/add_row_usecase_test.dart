import 'package:flutter_test/flutter_test.dart';
import 'package:m3_pad/src/core/utils/id_generator.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/customer.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/enums/enums.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/sheet_row.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/staff.dart';
import 'package:m3_pad/src/features/voucher/domain/repositories/customer_repository.dart';
import 'package:m3_pad/src/features/voucher/domain/repositories/sheet_row_repository.dart';
import 'package:m3_pad/src/features/voucher/domain/repositories/staff_repository.dart';
import 'package:m3_pad/src/features/voucher/domain/usecases/add_row_usecase.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'add_row_usecase_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<CustomerRepository>(),
  MockSpec<StaffRepository>(),
  MockSpec<SheetRowRepository>(),
  MockSpec<IdGenerator>(),
])
void main() {
  group('AddRowUsecase', () {
    late MockCustomerRepository customerRepository;
    late MockStaffRepository staffRepository;
    late MockSheetRowRepository rowRepository;
    late MockIdGenerator idGenerator;
    late AddRowUsecase usecase;

    final DateTime now = DateTime(2026, 9, 28);

    setUp(() {
      customerRepository = MockCustomerRepository();
      staffRepository = MockStaffRepository();
      rowRepository = MockSheetRowRepository();
      idGenerator = MockIdGenerator();
      usecase = AddRowUsecase(
        customerRepository: customerRepository,
        staffRepository: staffRepository,
        rowRepository: rowRepository,
        idGenerator: idGenerator,
      );

      when(idGenerator.generate()).thenReturn('row-2');
    });

    test('assigns rowOrder as one past the current maximum', () async {
      when(
        rowRepository.findMaxRowOrder('instance-1'),
      ).thenAnswer((final _) async => 3);

      final SheetRow row = await usecase('instance-1');

      expect(row.rowOrder, 4);
      expect(row.totalAmount, 0);
      expect(row.status, RecordStatus.active);
      verify(rowRepository.insert(row)).called(1);
    });

    test('starts rowOrder at 1 when the instance has no rows yet', () async {
      when(
        rowRepository.findMaxRowOrder('instance-1'),
      ).thenAnswer((final _) async => 0);

      final SheetRow row = await usecase('instance-1');

      expect(row.rowOrder, 1);
    });

    test(
      'validates the customer exists before adding a row linked to it',
      () async {
        when(
          rowRepository.findMaxRowOrder('instance-1'),
        ).thenAnswer((final _) async => 0);
        when(customerRepository.findById('customer-1')).thenAnswer(
          (final _) async => Customer(
            customerId: 'customer-1',
            name: '田中',
            gender: Gender.none,
            status: RecordStatus.active,
            createdAt: now,
            updatedAt: now,
          ),
        );

        final SheetRow row = await usecase(
          'instance-1',
          customerId: 'customer-1',
        );

        expect(row.customerId, 'customer-1');
        verify(customerRepository.findById('customer-1')).called(1);
      },
    );

    test(
      'validates the staff member exists before adding a row assigned to '
      'them',
      () async {
        when(
          rowRepository.findMaxRowOrder('instance-1'),
        ).thenAnswer((final _) async => 0);
        when(staffRepository.findById('staff-1')).thenAnswer(
          (final _) async => Staff(
            staffId: 'staff-1',
            name: '山田',
            status: RecordStatus.active,
            createdAt: now,
            updatedAt: now,
          ),
        );

        final SheetRow row = await usecase('instance-1', staffId: 'staff-1');

        expect(row.staffId, 'staff-1');
        verify(staffRepository.findById('staff-1')).called(1);
      },
    );

    test('does not look up a customer or staff member when none given',
        () async {
      when(
        rowRepository.findMaxRowOrder('instance-1'),
      ).thenAnswer((final _) async => 0);

      await usecase('instance-1');

      verifyNever(customerRepository.findById(any));
      verifyNever(staffRepository.findById(any));
    });
  });
}
