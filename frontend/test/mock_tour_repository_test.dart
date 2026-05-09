import 'package:flutter_test/flutter_test.dart';

import 'package:tur_izim/core/bootstrap/tur_izim_mock_bootstrap.dart';
import 'package:tur_izim/core/constants/mock_actor_ids.dart';
import 'package:tur_izim/features/tours/domain/tour_repository.dart';
import 'package:tur_izim/shared/models/tour_status.dart';

void main() {
  group('MockTourRepository', () {
    late TourRepository repo;

    setUp(() {
      final bootstrap = TurIzimMockBootstrap();
      repo = bootstrap.tours;
    });

    test('fetchPublishedTours iki yayımlanmış ilan döndürür', () async {
      final list = await repo.fetchPublishedTours();
      expect(list.length, 2);
      expect(list.first.departureCity, 'Adana');
      expect(list.any((t) => t.title.contains('Mersin')), isTrue);
    });

    test('fetchTourDetail — başlık ve acente görünen adı', () async {
      final detail = await repo.fetchTourDetail(MockActorIds.tourKapadokya);
      expect(detail, isNotNull);
      expect(detail!.title, contains('Kapadokya'));
      expect(detail.agencyLegalName, isNotEmpty);
      expect(detail.requirements, isNotEmpty);
      expect(detail.normalSalesPrice, greaterThan(0));
      expect(detail.expectedDepositAmount, greaterThan(0));
      expect(
        detail.expectedDepositAmount,
        lessThanOrEqualTo(detail.normalSalesPrice),
      );
    });

    test('fetchAgencyTours onaylı acente için iki ilan döndürür', () async {
      final list = await repo.fetchAgencyTours(MockActorIds.approvedAgency);
      expect(list.length, 2);
      expect(list.every((t) => t.status == TourStatus.published), isTrue);
    });
  });
}
