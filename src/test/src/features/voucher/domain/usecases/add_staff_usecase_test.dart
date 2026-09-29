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
  });
}
