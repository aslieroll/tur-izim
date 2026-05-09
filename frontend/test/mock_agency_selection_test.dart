import 'package:flutter_test/flutter_test.dart';

import 'package:tur_izim/core/constants/mock_actor_ids.dart';
import 'package:tur_izim/core/errors/app_exception.dart';
import 'package:tur_izim/core/mock/mock_tur_izim_store.dart';
import 'package:tur_izim/shared/models/application_commitment.dart';
import 'package:tur_izim/shared/models/assignment_status.dart';
import 'package:tur_izim/shared/models/mock_deposit_status.dart';

void main() {
  group('agencySelectApplicant', () {
    late MockTurIzimStore store;

    setUp(() => store = MockTurIzimStore());

    test('creates assignment with pending mock deposit', () async {
      await store.agencySelectApplicant(
        actingAgencyId: MockActorIds.approvedAgency,
        tourId: MockActorIds.tourKapadokya,
        applicationId: MockTurIzimStore.applicationAliceId,
      );

      final aliceAssignments = store.assignmentsForCreator(
        MockActorIds.creatorAlice,
      );
      expect(aliceAssignments, hasLength(1));
      expect(
        aliceAssignments.single.status,
        AssignmentStatus.awaitingCreatorConfirmation,
      );
      final id = aliceAssignments.single.id;
      expect(store.depositsByAssignmentId.containsKey(id), isTrue);
      expect(
        store.depositsByAssignmentId[id]!.status,
        MockDepositStatus.pending,
      );

      final detail = store.assignmentDetailForViewer(
        assignmentId: id,
        viewerCreatorId: MockActorIds.creatorAlice,
        viewerAgencyId: null,
      );
      expect(detail.deposit, isNotNull);
      expect(detail.deposit!.status, MockDepositStatus.pending);
      expect(detail.deposit!.tourId, MockActorIds.tourKapadokya);
      expect(detail.deposit!.creatorId, MockActorIds.creatorAlice);
    });

    test('duplicate selection throws', () async {
      await store.agencySelectApplicant(
        actingAgencyId: MockActorIds.approvedAgency,
        tourId: MockActorIds.tourKapadokya,
        applicationId: MockTurIzimStore.applicationAliceId,
      );
      await expectLater(
        store.agencySelectApplicant(
          actingAgencyId: MockActorIds.approvedAgency,
          tourId: MockActorIds.tourKapadokya,
          applicationId: MockTurIzimStore.applicationAliceId,
        ),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('creatorConfirmDeposit (kesin onay)', () {
    late MockTurIzimStore store;

    setUp(() => store = MockTurIzimStore());

    test(
      'awaitingCreatorConfirmation: PENDING → HELD ve atama active',
      () async {
        await store.agencySelectApplicant(
          actingAgencyId: MockActorIds.approvedAgency,
          tourId: MockActorIds.tourKapadokya,
          applicationId: MockTurIzimStore.applicationAliceId,
        );
        final id = store
            .assignmentsForCreator(MockActorIds.creatorAlice)
            .single
            .id;

        await store.creatorConfirmDeposit(
          assignmentId: id,
          creatorId: MockActorIds.creatorAlice,
          commitment: const ApplicationCommitment(
            acceptedPublicationCommitment: true,
            acceptedContentUsagePermission: true,
            acceptedTourPriceClaimCondition: true,
          ),
        );

        final after = store
            .assignmentsForCreator(MockActorIds.creatorAlice)
            .single;
        expect(after.status, AssignmentStatus.active);
        expect(
          store.depositsByAssignmentId[id]!.status,
          MockDepositStatus.held,
        );
      },
    );
  });
}
