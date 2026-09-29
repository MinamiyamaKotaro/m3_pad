import 'package:flutter_test/flutter_test.dart';
import 'package:m3_pad/src/core/errors/validation_exception.dart';
import 'package:m3_pad/src/core/utils/id_generator.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/enums/enums.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/staff.dart';
import 'package:m3_pad/src/features/voucher/domain/repositories/staff_repository.dart';
import 'package:m3_pad/src/features/voucher/domain/usecases/add_staff_usecase.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'add_staff_usecase_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<StaffRepository>(),
  MockSpec<IdGenerator>(),
])
void main() {
  group('AddStaffUsecase', () {
    late MockStaffRepository staffRepository;
    late MockIdGenerator idGenerator;
    late AddStaffUsecase usecase;

    setUp(() {
      staffRepository = MockStaffRepository();
      idGenerator = MockIdGenerator();
      usecase = AddStaffUsecase(
        staffRepository: staffRepository,
        idGenerator: idGenerator,
      );
      when(idGenerator.generate()).thenReturn('staff-1');
    });

    test('adds an active staff member with the given name', () async {
      when(staffRepository.findByName('山田'))
          .thenAnswer((final _) async => null);

      final Staff staff = await usecase(name: '山田');

      expect(staff.staffId, 'staff-1');
      expect(staff.name, '山田');
      expect(staff.status, RecordStatus.active);
      verify(staffRepository.insert(staff)).called(1);
    });

    test('throws ValidationException when the name is blank', () {
      expect(
        () => usecase(name: '  '),
        throwsA(isA<ValidationException>()),
      );
      verifyNever(staffRepository.insert(any));
    });

    test(
      'restores a logically deleted staff member with the same name '
      'instead of creating a duplicate',
      () async {
        final DateTime now = DateTime(2026, 9, 28);
        final Staff deleted = Staff(
          staffId: 'staff-old',
          name: '山田',
          status: RecordStatus.deleted,
          createdAt: now,
          updatedAt: now,
        );
        when(staffRepository.findByName('山田'))
            .thenAnswer((final _) async => deleted);

        final Staff staff = await usecase(name: '山田');

        expect(staff.staffId, 'staff-old');
        expect(staff.status, RecordStatus.active);
        verify(
          staffRepository.updateStatus('staff-old', RecordStatus.active),
        ).called(1);
        verifyNever(staffRepository.insert(any));
      },
    );

    test(
      'adds a new staff member as usual when an active staff member '
      'already has the same name',
      () async {
        final DateTime now = DateTime(2026, 9, 28);
        final Staff active = Staff(
          staffId: 'staff-existing',
          name: '山田',
          status: RecordStatus.active,
          createdAt: now,
          updatedAt: now,
        );
        when(staffRepository.findByName('山田'))
            .thenAnswer((final _) async => active);

        final Staff staff = await usecase(name: '山田');

        expect(staff.staffId, 'staff-1');
        verify(staffRepository.insert(staff)).called(1);
        verifyNever(staffRepository.updateStatus(any, any));
      },
    );
  });
}
