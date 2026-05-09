import 'package:flutter_test/flutter_test.dart';

import 'package:tur_izim/core/errors/app_exception.dart';
import 'package:tur_izim/shared/domain/tour_pricing_rules.dart';
import 'package:tur_izim/shared/models/destination_cluster.dart';
import 'package:tur_izim/shared/models/departure_region.dart';
import 'package:tur_izim/shared/models/tour_status.dart';
import 'package:tur_izim/shared/models/tour_summary.dart';

TourSummary _publishedStub({required double normal, required double deposit}) {
  final start = DateTime.utc(2026, 6, 1);
  return TourSummary(
    id: 't-test',
    agencyId: 'agency-test',
    title: 'Test tur',
    description: 'd',
    departureCity: 'Adana',
    departureRegion: DepartureRegion.adana,
    destinationCluster: DestinationCluster.kapadokya,
    status: TourStatus.published,
    startsAt: start,
    endsAt: start.add(const Duration(days: 2)),
    transportationIncluded: true,
    seatsOffered: 10,
    creatorQuota: 2,
    expectedDepositAmount: deposit,
    normalSalesPrice: normal,
    currency: 'TRY',
    acceptedAssignmentCount: 0,
    pendingApplicationCount: 0,
    agencyLegalName: 'Test acente',
  );
}

void main() {
  group('TourPricingRules', () {
    test('geçerli yayındaki ilan sorun çıkarmaz', () {
      expect(
        () => TourPricingRules.validatePublishedTour(
          _publishedStub(normal: 3500, deposit: 1500),
        ),
        returnsNormally,
      );
    });

    test('depozito normal fiyattan büyükse AppException', () {
      expect(
        () => TourPricingRules.validatePublishedTour(
          _publishedStub(normal: 1000, deposit: 1001),
        ),
        throwsA(isA<AppException>()),
      );
    });

    test('taslak tur doğrulanmaz', () {
      final draft = TourSummary(
        id: 't-draft',
        agencyId: 'a',
        title: 'x',
        description: 'y',
        departureCity: 'Adana',
        departureRegion: DepartureRegion.adana,
        destinationCluster: DestinationCluster.guney,
        status: TourStatus.draft,
        startsAt: DateTime.utc(2026, 7, 1),
        endsAt: DateTime.utc(2026, 7, 3),
        transportationIncluded: false,
        seatsOffered: 8,
        creatorQuota: 1,
        expectedDepositAmount: 0,
        normalSalesPrice: 0,
        currency: 'TRY',
        acceptedAssignmentCount: 0,
        pendingApplicationCount: 0,
      );
      expect(
        () => TourPricingRules.validatePublishedTour(draft),
        returnsNormally,
      );
    });
  });
}
