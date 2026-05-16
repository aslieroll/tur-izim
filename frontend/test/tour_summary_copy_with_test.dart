import 'package:flutter_test/flutter_test.dart';
import 'package:tur_izim/shared/models/departure_region.dart';
import 'package:tur_izim/shared/models/destination_cluster.dart';
import 'package:tur_izim/shared/models/tour_scope.dart';
import 'package:tur_izim/shared/models/tour_status.dart';
import 'package:tur_izim/shared/models/tour_summary.dart';

void main() {
  test('TourSummary.copyWith günceller; diğer alanlar korunur', () {
    final base = TourSummary(
      id: 't1',
      agencyId: 'a1',
      title: 'X',
      description: 'd',
      departureCity: 'Adana',
      departureRegion: DepartureRegion.adana,
      destinationCity: 'Kapadokya',
      destinationCluster: DestinationCluster.kapadokya,
      status: TourStatus.published,
      startsAt: DateTime.utc(2026, 6, 1),
      endsAt: DateTime.utc(2026, 6, 5),
      transportationIncluded: true,
      seatsOffered: 4,
      creatorQuota: 4,
      expectedDepositAmount: 100,
      normalSalesPrice: 500,
      acceptedAssignmentCount: 0,
      pendingApplicationCount: 0,
      tourScope: TourScope.domestic,
    );

    final next = base.copyWith(
      pendingApplicationCount: 2,
      acceptedAssignmentCount: 1,
    );

    expect(next.pendingApplicationCount, 2);
    expect(next.acceptedAssignmentCount, 1);
    expect(next.title, 'X');
    expect(next.agencyId, 'a1');
  });
}
