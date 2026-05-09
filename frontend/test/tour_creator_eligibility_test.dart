import 'package:flutter_test/flutter_test.dart';

import 'package:tur_izim/shared/domain/tour_creator_eligibility.dart';
import 'package:tur_izim/shared/models/creator_profile.dart';
import 'package:tur_izim/shared/models/destination_cluster.dart';
import 'package:tur_izim/shared/models/departure_region.dart';
import 'package:tur_izim/shared/models/passport_type.dart';
import 'package:tur_izim/shared/models/tour_scope.dart';
import 'package:tur_izim/shared/models/tour_status.dart';
import 'package:tur_izim/shared/models/tour_summary.dart';
import 'package:tur_izim/shared/models/visa_eligibility_status.dart';

TourSummary _intlTour() {
  final s = DateTime.utc(2026, 9, 1);
  return TourSummary(
    id: 'x',
    agencyId: 'a',
    title: 't',
    description: 'd',
    departureCity: 'İzmir',
    departureRegion: DepartureRegion.adana,
    destinationCluster: DestinationCluster.guney,
    status: TourStatus.published,
    startsAt: s,
    endsAt: s.add(const Duration(days: 3)),
    transportationIncluded: true,
    seatsOffered: 10,
    creatorQuota: 2,
    expectedDepositAmount: 1000,
    normalSalesPrice: 5000,
    acceptedAssignmentCount: 0,
    pendingApplicationCount: 0,
    tourScope: TourScope.international,
    requiresPassport: true,
    minimumPassportType: PassportType.bordo,
    requiresVisa: true,
    visaRequirementText: 'Schengen',
  );
}

void main() {
  group('TourCreatorEligibility', () {
    test('yurt içi her zaman uygun', () {
      final domestic = TourSummary(
        id: 'd',
        agencyId: 'a',
        title: 't',
        description: 'd',
        departureCity: 'Adana',
        departureRegion: DepartureRegion.adana,
        destinationCluster: DestinationCluster.kapadokya,
        status: TourStatus.published,
        startsAt: DateTime.utc(2026, 6, 1),
        endsAt: DateTime.utc(2026, 6, 3),
        transportationIncluded: true,
        seatsOffered: 10,
        creatorQuota: 2,
        expectedDepositAmount: 500,
        normalSalesPrice: 2000,
        acceptedAssignmentCount: 0,
        pendingApplicationCount: 0,
      );
      const profile = CreatorProfile(
        id: 'p',
        displayName: 'x',
        instagramUrl: null,
        tiktokUrl: null,
        youtubeUrl: null,
        portfolioUrl: null,
        hasPublicInstagram: false,
        hasPublicTiktok: false,
        canCreateVerticalVideo: false,
        canShootPhotos: false,
        canDeliverRawFiles: false,
        hasBasicEditingSkill: false,
        hasTravelVlogExperience: false,
        canRecord1080pVideo: false,
        passportType: PassportType.none,
        hasValidPassport: false,
        visaEligibility: VisaEligibilityStatus.none,
      );
      expect(
        TourCreatorEligibility.isEligible(profile: profile, tour: domestic),
        isTrue,
      );
    });

    test('yurt dışı: pasaport geçersizse uygun değil', () {
      const profile = CreatorProfile(
        id: 'p',
        displayName: 'x',
        instagramUrl: null,
        tiktokUrl: null,
        youtubeUrl: null,
        portfolioUrl: null,
        hasPublicInstagram: false,
        hasPublicTiktok: false,
        canCreateVerticalVideo: false,
        canShootPhotos: false,
        canDeliverRawFiles: false,
        hasBasicEditingSkill: false,
        hasTravelVlogExperience: false,
        canRecord1080pVideo: false,
        passportType: PassportType.bordo,
        hasValidPassport: false,
        visaEligibility: VisaEligibilityStatus.hasRequiredVisa,
      );
      expect(
        TourCreatorEligibility.isEligible(profile: profile, tour: _intlTour()),
        isFalse,
      );
    });

    test('yurt dışı: vize beyanı yoksa uygun değil', () {
      const profile = CreatorProfile(
        id: 'p',
        displayName: 'x',
        instagramUrl: null,
        tiktokUrl: null,
        youtubeUrl: null,
        portfolioUrl: null,
        hasPublicInstagram: false,
        hasPublicTiktok: false,
        canCreateVerticalVideo: false,
        canShootPhotos: false,
        canDeliverRawFiles: false,
        hasBasicEditingSkill: false,
        hasTravelVlogExperience: false,
        canRecord1080pVideo: false,
        passportType: PassportType.bordo,
        hasValidPassport: true,
        visaEligibility: VisaEligibilityStatus.none,
      );
      expect(
        TourCreatorEligibility.isEligible(profile: profile, tour: _intlTour()),
        isFalse,
      );
    });
  });
}
