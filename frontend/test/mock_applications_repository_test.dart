import 'package:flutter_test/flutter_test.dart';

import 'package:tur_izim/core/bootstrap/tur_izim_mock_bootstrap.dart';
import 'package:tur_izim/core/constants/mock_actor_ids.dart';
import 'package:tur_izim/core/errors/app_exception.dart';
import 'package:tur_izim/features/applications/domain/applications_repository.dart';
import 'package:tur_izim/shared/models/application_commitment.dart';
import 'package:tur_izim/shared/models/application_status.dart';

void main() {
  group('MockApplicationsRepository', () {
    late ApplicationsRepository repo;

    setUp(() {
      final bootstrap = TurIzimMockBootstrap.mockOnly();
      repo = bootstrap.applications;
    });

    test('listByCreator — Alice için Kapadokya başvurusu', () async {
      final list = await repo.listByCreator(MockActorIds.creatorAlice);
      expect(list.length, 1);
      expect(list.first.tourId, MockActorIds.tourKapadokya);
    });

    test('listByCreator — liste satırında tur adı ve AUE', () async {
      final list = await repo.listByCreator(MockActorIds.creatorAlice);
      expect(list.first.tourTitle, isNotNull);
      expect(list.first.suitabilityAue, 88.0);
      expect(list.first.status, ApplicationStatus.pendingReview);
    });

    test('listByCreator — Bob için tek başvuru', () async {
      final list = await repo.listByCreator(MockActorIds.creatorBob);
      expect(list.length, 1);
    });

    test(
      'listRatedApplicantsForTour — önceden hesaplanmış AUE skorları',
      () async {
        final rated = await repo.listRatedApplicantsForTour(
          actingAgencyId: MockActorIds.approvedAgency,
          tourId: MockActorIds.tourKapadokya,
        );
        expect(rated.length, 3);
        expect(rated.first.scores.aue, 88);
        expect(rated[1].scores.aue, 76);
        expect(rated.last.scores.aue, 62);
      },
    );

    test('submitApplication — yeni mock kayıt', () async {
      await repo.submitApplication(
        creatorId: MockActorIds.creatorAlice,
        tourId: MockActorIds.tourAntalyaCoast,
        commitment: const ApplicationCommitment(
          acceptedPublicationCommitment: true,
          acceptedContentUsagePermission: true,
          acceptedTourPriceClaimCondition: true,
        ),
      );
      final list = await repo.listByCreator(MockActorIds.creatorAlice);
      expect(
        list.any((a) => a.tourId == MockActorIds.tourAntalyaCoast),
        isTrue,
      );
      final row = list.firstWhere(
        (a) => a.tourId == MockActorIds.tourAntalyaCoast,
      );
      expect(row.status, ApplicationStatus.pendingReview);
      expect(row.suitabilityAue, isNotNull);
    });

    test('submitApplication — mükerrer reddi', () async {
      await expectLater(
        () => repo.submitApplication(
          creatorId: MockActorIds.creatorAlice,
          tourId: MockActorIds.tourKapadokya,
          commitment: const ApplicationCommitment(
            acceptedPublicationCommitment: true,
            acceptedContentUsagePermission: true,
            acceptedTourPriceClaimCondition: true,
          ),
        ),
        throwsA(isA<AppException>()),
      );
    });
  });
}
