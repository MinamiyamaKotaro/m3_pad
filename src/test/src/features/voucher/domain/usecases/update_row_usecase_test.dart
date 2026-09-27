import 'package:flutter_test/flutter_test.dart';
import 'package:m3_pad/src/core/utils/id_generator.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/customer.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/enums/enums.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/sheet_row.dart';
import 'package:m3_pad/src/features/voucher/domain/repositories/customer_repository.dart';
import 'package:m3_pad/src/features/voucher/domain/repositories/sheet_row_repository.dart';
import 'package:m3_pad/src/features/voucher/domain/usecases/update_row_usecase.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'update_row_usecase_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<SheetRowRepository>(),
  MockSpec<CustomerRepository>(),
  MockSpec<IdGenerator>(),
])
void main() {
  group('UpdateRowUsecase', () {
    late MockSheetRowRepository rowRepository;
    late MockCustomerRepository customerRepository;
    late MockIdGenerator idGenerator;
    late UpdateRowUsecase usecase;

    final DateTime now = DateTime(2026, 9, 28);
    final SheetRow current = SheetRow(
      rowId: 'row-1',
      sheetInstanceId: 'instance-1',
      rowOrder: 1,
      totalAmount: 1200,
      status: RecordStatus.active,
      createdAt: now,
      updatedAt: now,
    );

    setUp(() {
      rowRepository = MockSheetRowRepository();
      customerRepository = MockCustomerRepository();
      idGenerator = MockIdGenerator();
      usecase = UpdateRowUsecase(
        rowRepository: rowRepository,
        customerRepository: customerRepository,
        idGenerator: idGenerator,
      );
    });

    test(
      'creates a new customer and links it when the row has no customer yet',
      () async {
        when(idGenerator.generate()).thenReturn('customer-1');

        final SheetRow updated = await usecase(current, customerName: '田中');

        expect(updated.customerId, 'customer-1');
        final Customer inserted = verify(customerRepository.insert(captureAny))
            .captured
            .single as Customer;
        expect(inserted.name, '田中');
        verify(rowRepository.update(updated)).called(1);
      },
    );

    test('clears the customer link when customerName is empty', () async {
      final SheetRow linked = SheetRow(
        rowId: 'row-1',
        sheetInstanceId: 'instance-1',
        customerId: 'customer-1',
        rowOrder: 1,
        totalAmount: 1200,
        status: RecordStatus.active,
        createdAt: now,
        updatedAt: now,
      );

      final SheetRow updated = await usecase(linked, customerName: '');

      expect(updated.customerId, isNull);
      verifyNever(customerRepository.insert(any));
    });

    test('leaves the customer link untouched when customerName is null',
        () async {
      final SheetRow linked = SheetRow(
        rowId: 'row-1',
        sheetInstanceId: 'instance-1',
        customerId: 'customer-1',
        rowOrder: 1,
        totalAmount: 1200,
        status: RecordStatus.active,
        createdAt: now,
        updatedAt: now,
      );

      final SheetRow updated = await usecase(linked);

      expect(updated.customerId, 'customer-1');
    });

    test('sets staffId to null when hasStaffId is true and staffId is null',
        () async {
      final SheetRow staffed = SheetRow(
        rowId: 'row-1',
        sheetInstanceId: 'instance-1',
        staffId: 'staff-1',
        rowOrder: 1,
        totalAmount: 1200,
        status: RecordStatus.active,
        createdAt: now,
        updatedAt: now,
      );

      final SheetRow updated = await usecase(staffed, hasStaffId: true);

      expect(updated.staffId, isNull);
    });

    test('leaves staffId untouched when hasStaffId is false', () async {
      final SheetRow staffed = SheetRow(
        rowId: 'row-1',
        sheetInstanceId: 'instance-1',
        staffId: 'staff-1',
        rowOrder: 1,
        totalAmount: 1200,
        status: RecordStatus.active,
        createdAt: now,
        updatedAt: now,
      );

      final SheetRow updated = await usecase(staffed);

      expect(updated.staffId, 'staff-1');
    });

    test('updates paymentMethod only when hasPaymentMethod is true', () async {
      final SheetRow updated = await usecase(
        current,
        paymentMethod: PaymentMethod.card,
        hasPaymentMethod: true,
      );

      expect(updated.paymentMethod, PaymentMethod.card);
    });
  });
}
