import 'package:flutter_test/flutter_test.dart';
import 'package:m3_pad/src/core/errors/validation_exception.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/enums/enums.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/staff.dart';
import 'package:m3_pad/src/features/voucher/domain/repositories/staff_repository.dart';
import 'package:m3_pad/src/features/voucher/domain/usecases/update_staff_usecase.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'update_staff_usecase_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[MockSpec<StaffRepository>()])
void main() {
  group('UpdateStaffUsecase', () {
    late MockStaffRepository staffRepository;
    late UpdateStaffUsecase usecase;

    final DateTime now = DateTime(2026, 9, 29);
    final Staff staff = Staff(
      staffId: 'staff-1',
      name: '山田',
      status: RecordStatus.active,
      createdAt: now,
      updatedAt: now,
    );

    setUp(() {
      staffRepository = MockStaffRepository();
      usecase = UpdateStaffUsecase(staffRepository: staffRepository);
      when(
        staffRepository.findById('staff-1'),
      ).thenAnswer((final _) async => staff);
    });

    test('updates the staff name after confirming the staff exists', () async {
      await usecase(staffId: 'staff-1', name: '田中');

      verify(staffRepository.findById('staff-1')).called(1);
      verify(staffRepository.updateName('staff-1', '田中')).called(1);
    });

    test('throws ValidationException when the name is blank', () {
      expect(
        () => usecase(staffId: 'staff-1', name: ' '),
        throwsA(isA<ValidationException>()),
      );
    });
  });
}
