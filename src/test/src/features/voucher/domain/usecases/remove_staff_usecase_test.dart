import 'package:flutter_test/flutter_test.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/enums/enums.dart';
import 'package:m3_pad/src/features/voucher/domain/entities/staff.dart';
import 'package:m3_pad/src/features/voucher/domain/repositories/staff_repository.dart';
import 'package:m3_pad/src/features/voucher/domain/usecases/remove_staff_usecase.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'remove_staff_usecase_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[MockSpec<StaffRepository>()])
void main() {
  group('RemoveStaffUsecase', () {
    late MockStaffRepository staffRepository;
    late RemoveStaffUsecase usecase;

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
      usecase = RemoveStaffUsecase(staffRepository: staffRepository);
      when(
        staffRepository.findById('staff-1'),
      ).thenAnswer((final _) async => staff);
    });

    test(
      'logically deletes the staff member after confirming they exist',
      () async {
        await usecase('staff-1');

        verify(staffRepository.findById('staff-1')).called(1);
        verify(
          staffRepository.updateStatus('staff-1', RecordStatus.deleted),
        ).called(1);
      },
    );
  });
}
