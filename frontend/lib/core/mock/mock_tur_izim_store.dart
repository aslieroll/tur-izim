import 'package:tur_izim/core/errors/app_exception.dart';
import 'package:tur_izim/shared/models/agency_status.dart';
import 'package:tur_izim/shared/models/application_commitment.dart';
import 'package:tur_izim/shared/models/application_status.dart';
import 'package:tur_izim/shared/models/application_summary.dart';
import 'package:tur_izim/shared/models/assignment_status.dart';
import 'package:tur_izim/shared/models/assignment_detail.dart';
import 'package:tur_izim/shared/models/assignment_summary.dart';
import 'package:tur_izim/shared/models/assignment_timeline_step.dart';
import 'package:tur_izim/shared/models/content_delivery.dart';
import 'package:tur_izim/shared/models/content_delivery_status.dart';
import 'package:tur_izim/shared/models/creator_profile.dart';
import 'package:tur_izim/shared/models/destination_cluster.dart';
import 'package:tur_izim/shared/models/mock_deposit.dart';
import 'package:tur_izim/shared/models/mock_deposit_status.dart';
import 'package:tur_izim/shared/models/pending_agency_review.dart';
import 'package:tur_izim/shared/models/publication_record.dart';
import 'package:tur_izim/shared/models/publication_status.dart';
import 'package:tur_izim/shared/models/rated_application.dart';
import 'package:tur_izim/shared/models/social_platform.dart';
import 'package:tur_izim/shared/models/suitability_scores.dart';
import 'package:tur_izim/shared/models/tour_detail.dart';
import 'package:tur_izim/shared/models/passport_type.dart';
import 'package:tur_izim/shared/models/tour_requirement_type.dart';
import 'package:tur_izim/shared/models/tour_status.dart';
import 'package:tur_izim/shared/models/tour_summary.dart';
import 'package:tur_izim/shared/models/visa_eligibility_status.dart';
import 'package:tur_izim/shared/models/violation_report.dart';
import 'package:tur_izim/core/constants/mock_actor_ids.dart';
import 'package:tur_izim/shared/domain/tour_creator_eligibility.dart';
import 'package:tur_izim/shared/domain/tour_pricing_rules.dart';
import 'package:tur_izim/shared/models/violation_report_status.dart';
import 'package:tur_izim/shared/models/departure_region.dart';

/// File-local mutable rows (mock backend); not used by presentation directly.
class _ApplicationRow {
  _ApplicationRow({
    required this.id,
    required this.tourId,
    required this.creatorId,
    required this.status,
    required this.message,
    required this.acceptedPublicationCommitment,
    required this.acceptedContentUsagePermission,
    required this.acceptedTourPriceClaimCondition,
    required this.scores,
    required this.createdAt,
    required this.updatedAt,
  });

  String id;
  String tourId;
  String creatorId;
  ApplicationStatus status;
  String? message;
  bool acceptedPublicationCommitment;
  bool acceptedContentUsagePermission;
  bool acceptedTourPriceClaimCondition;
  SuitabilityScores scores;
  DateTime createdAt;
  DateTime updatedAt;
}

class _AssignmentRow {
  _AssignmentRow({
    required this.id,
    required this.tourId,
    required this.creatorId,
    required this.applicationId,
    required this.status,
    required this.selectedAt,
    required this.creatorDepositAcknowledgedAt,
    required this.updatedAt,
  });

  String id;
  String tourId;
  String creatorId;
  String applicationId;
  AssignmentStatus status;
  DateTime selectedAt;
  DateTime? creatorDepositAcknowledgedAt;
  DateTime updatedAt;
}

class _TourRow {
  _TourRow({required this.detail});

  TourDetail detail;
}

class _AgencyRow {
  _AgencyRow({required this.id, required this.legalName, required this.status});

  String id;
  String legalName;
  AgencyStatus status;
}

/// Coordinated in-memory persistence for all mock repositories.
final class MockTurIzimStore {
  MockTurIzimStore() {
    _seed();
  }

  final Map<String, CreatorProfile> creators = {};
  final Map<String, _AgencyRow> _agencies = {};
  final Map<String, _TourRow> _tours = {};
  final List<_ApplicationRow> _applications = [];
  final List<_AssignmentRow> _assignments = [];
  final Map<String, MockDeposit> depositsByAssignmentId = {};
  final Map<String, ContentDelivery> deliveriesByAssignmentId = {};
  final Map<String, PublicationRecord> publicationsByAssignmentId = {};
  final List<ViolationReport> violations = [];

  static const String approvedAgencyId = MockActorIds.approvedAgency;
  static const String pendingAgencyId = MockActorIds.pendingAgency;
  static const String creatorAliceId = MockActorIds.creatorAlice;
  static const String creatorBobId = MockActorIds.creatorBob;
  static const String creatorCerenId = 'creator-ceren';
  static const String tourKapadokyaId = MockActorIds.tourKapadokya;
  static const String tourAntalyaId = MockActorIds.tourAntalyaCoast;
  static const String applicationAliceId = 'app-alice-kapadokya';
  static const String applicationBobId = 'app-bob-kapadokya';
  static const String applicationCerenId = 'app-ceren-kapadokya';

  void _seed() {
    creators[creatorAliceId] = CreatorProfile(
      id: creatorAliceId,
      displayName: 'Ayşe (UGC)',
      instagramUrl: 'https://instagram.com/mock-alice',
      tiktokUrl: null,
      youtubeUrl: null,
      portfolioUrl: 'https://example.com/alice',
      hasPublicInstagram: true,
      hasPublicTiktok: false,
      canCreateVerticalVideo: true,
      canShootPhotos: true,
      canDeliverRawFiles: true,
      hasBasicEditingSkill: true,
      hasTravelVlogExperience: true,
      canRecord1080pVideo: true,
      passportType: PassportType.bordo,
      hasValidPassport: true,
      visaEligibility: VisaEligibilityStatus.hasRequiredVisa,
    );

    creators[creatorBobId] = CreatorProfile(
      id: creatorBobId,
      displayName: 'Mehmet (Vlog)',
      instagramUrl: 'https://instagram.com/mock-bob',
      tiktokUrl: 'https://tiktok.com/@mock-bob',
      youtubeUrl: null,
      portfolioUrl: null,
      hasPublicInstagram: true,
      hasPublicTiktok: true,
      canCreateVerticalVideo: true,
      canShootPhotos: true,
      canDeliverRawFiles: false,
      hasBasicEditingSkill: true,
      hasTravelVlogExperience: false,
      canRecord1080pVideo: true,
      passportType: PassportType.bordo,
      hasValidPassport: false,
      visaEligibility: VisaEligibilityStatus.none,
    );

    creators[creatorCerenId] = CreatorProfile(
      id: creatorCerenId,
      displayName: 'Ceren (Micro Influencer)',
      instagramUrl: 'https://instagram.com/mock-ceren',
      tiktokUrl: null,
      youtubeUrl: null,
      portfolioUrl: 'https://example.com/ceren',
      hasPublicInstagram: true,
      hasPublicTiktok: false,
      canCreateVerticalVideo: true,
      canShootPhotos: true,
      canDeliverRawFiles: true,
      hasBasicEditingSkill: true,
      hasTravelVlogExperience: false,
      canRecord1080pVideo: true,
      passportType: PassportType.bordo,
      hasValidPassport: true,
      visaEligibility: VisaEligibilityStatus.none,
    );

    _agencies[approvedAgencyId] = _AgencyRow(
      id: approvedAgencyId,
      legalName: 'Adana Gezi Acentesi (Onaylı)',
      status: AgencyStatus.approved,
    );

    _agencies[pendingAgencyId] = _AgencyRow(
      id: pendingAgencyId,
      legalName: 'Mersin Turizm (Beklemede)',
      status: AgencyStatus.pendingApproval,
    );

    final tourStart = DateTime.utc(2026, 6, 10, 8);
    final tourEnd = DateTime.utc(2026, 6, 12, 20);

    _tours[tourKapadokyaId] = _TourRow(
      detail: TourDetail(
        id: tourKapadokyaId,
        agencyId: approvedAgencyId,
        title: 'Kapadokya — ulaşım dahil hafta sonu',
        description:
            'Pilot bölge ilanı. UGC içerik üreticileri ile boş koltuk '
            'doldurma senaryosu için mock veri.',
        departureCity: 'Adana',
        departureRegion: DepartureRegion.adana,
        destinationCluster: DestinationCluster.kapadokya,
        status: TourStatus.published,
        startsAt: tourStart,
        endsAt: tourEnd,
        transportationIncluded: true,
        seatsOffered: 18,
        creatorQuota: 2,
        expectedDepositAmount: 1500,
        normalSalesPrice: 3500,
        currency: 'TRY',
        acceptedAssignmentCount: 0,
        pendingApplicationCount: 2,
        requirements: const [
          TourRequirementType.min1080pVideo,
          TourRequirementType.verticalReelsFormat,
          TourRequirementType.instagramPublication,
          TourRequirementType.min5Photos,
          TourRequirementType.agencyBrandVisible,
        ],
      ),
    );

    final antalyaStart = DateTime.utc(2026, 7, 3, 7);
    final antalyaEnd = DateTime.utc(2026, 7, 5, 21);

    _tours[tourAntalyaId] = _TourRow(
      detail: TourDetail(
        id: tourAntalyaId,
        agencyId: approvedAgencyId,
        title: 'Mersin sahil — yaz içerik kampanyası',
        description:
            'Creator tarafında listelenecek ikinci yayımlı ilan (mock tohum '
            'veri).',
        departureCity: 'Mersin',
        departureRegion: DepartureRegion.mersin,
        destinationCluster: DestinationCluster.guney,
        status: TourStatus.published,
        startsAt: antalyaStart,
        endsAt: antalyaEnd,
        transportationIncluded: true,
        seatsOffered: 24,
        creatorQuota: 3,
        expectedDepositAmount: 2200,
        normalSalesPrice: 6900,
        currency: 'TRY',
        acceptedAssignmentCount: 0,
        pendingApplicationCount: 0,
        requirements: const [TourRequirementType.instagramPublication],
      ),
    );

    _applications.addAll([
      _ApplicationRow(
        id: applicationAliceId,
        tourId: tourKapadokyaId,
        creatorId: creatorAliceId,
        status: ApplicationStatus.pendingReview,
        message: 'Hafta sonu çekim planım hazır.',
        acceptedPublicationCommitment: true,
        acceptedContentUsagePermission: true,
        acceptedTourPriceClaimCondition: true,
        scores: const SuitabilityScores(
          aue: 88,
          technicalFit: 90,
          publicationFit: 82,
          matchedRequirementCount: 5,
          totalRequirementCount: 5,
          missingRequirementsText: '',
        ),
        createdAt: DateTime.utc(2026, 5, 1, 9),
        updatedAt: DateTime.utc(2026, 5, 1, 9),
      ),
      _ApplicationRow(
        id: applicationCerenId,
        tourId: tourKapadokyaId,
        creatorId: creatorCerenId,
        status: ApplicationStatus.pendingReview,
        message: 'Doğa/rota odaklı kısa içerik serisi hazırlayabilirim.',
        acceptedPublicationCommitment: true,
        acceptedContentUsagePermission: true,
        acceptedTourPriceClaimCondition: true,
        scores: const SuitabilityScores(
          aue: 76,
          technicalFit: 79,
          publicationFit: 70,
          matchedRequirementCount: 4,
          totalRequirementCount: 5,
          missingRequirementsText:
              'Travel vlog tecrübesi beklentisi kısmen karşılanmıyor.',
        ),
        createdAt: DateTime.utc(2026, 5, 2, 9),
        updatedAt: DateTime.utc(2026, 5, 2, 9),
      ),
      _ApplicationRow(
        id: applicationBobId,
        tourId: tourKapadokyaId,
        creatorId: creatorBobId,
        status: ApplicationStatus.pendingReview,
        message: null,
        acceptedPublicationCommitment: true,
        acceptedContentUsagePermission: true,
        acceptedTourPriceClaimCondition: true,
        scores: const SuitabilityScores(
          aue: 62,
          technicalFit: 54,
          publicationFit: 90,
          matchedRequirementCount: 3,
          totalRequirementCount: 5,
          missingRequirementsText:
              'Ham dosya teslimi ve seyahat vlog deneyimi beklentisi karşılanmıyor.',
        ),
        createdAt: DateTime.utc(2026, 5, 2, 11),
        updatedAt: DateTime.utc(2026, 5, 2, 11),
      ),
    ]);

    for (final id in _tours.keys.toList()) {
      _refreshTourCounters(id);
    }

    for (final row in _tours.values) {
      if (row.detail.status == TourStatus.published) {
        TourPricingRules.validatePublishedTour(row.detail);
      }
    }
  }

  String? _agencyLegalName(String agencyId) => _agencies[agencyId]?.legalName;

  TourDetail _cloneTourDetail(TourDetail source) {
    return TourDetail(
      id: source.id,
      agencyId: source.agencyId,
      title: source.title,
      description: source.description,
      departureCity: source.departureCity,
      departureRegion: source.departureRegion,
      destinationCluster: source.destinationCluster,
      status: source.status,
      startsAt: source.startsAt,
      endsAt: source.endsAt,
      transportationIncluded: source.transportationIncluded,
      seatsOffered: source.seatsOffered,
      creatorQuota: source.creatorQuota,
      expectedDepositAmount: source.expectedDepositAmount,
      normalSalesPrice: source.normalSalesPrice,
      currency: source.currency,
      acceptedAssignmentCount: source.acceptedAssignmentCount,
      pendingApplicationCount: source.pendingApplicationCount,
      agencyLegalName: _agencyLegalName(source.agencyId),
      tourScope: source.tourScope,
      requiresPassport: source.requiresPassport,
      minimumPassportType: source.minimumPassportType,
      requiresVisa: source.requiresVisa,
      visaRequirementText: source.visaRequirementText,
      requirements: List.of(source.requirements),
    );
  }

  TourSummary snapshotTourSummary(String tourId) {
    final tour = _tours[tourId]?.detail;
    if (tour == null) {
      throw AppException('Tur bulunamadı.');
    }
    return _cloneTourDetail(tour);
  }

  TourDetail snapshotTourDetail(String tourId) {
    final tour = _tours[tourId]?.detail;
    if (tour == null) {
      throw AppException('Tur bulunamadı.');
    }
    return _cloneTourDetail(tour);
  }

  TourSummary? _optionalTourSummary(String tourId) {
    final tour = _tours[tourId]?.detail;
    if (tour == null) return null;
    return _cloneTourDetail(tour);
  }

  void _refreshTourCounters(String tourId) {
    final row = _tours[tourId];
    if (row == null) return;
    final accepted = _assignments
        .where(
          (a) => a.tourId == tourId && a.status != AssignmentStatus.cancelled,
        )
        .length;
    final pendingApps = _applications
        .where(
          (a) =>
              a.tourId == tourId && a.status == ApplicationStatus.pendingReview,
        )
        .length;

    row.detail = TourDetail(
      id: row.detail.id,
      agencyId: row.detail.agencyId,
      title: row.detail.title,
      description: row.detail.description,
      departureCity: row.detail.departureCity,
      departureRegion: row.detail.departureRegion,
      destinationCluster: row.detail.destinationCluster,
      status: row.detail.status,
      startsAt: row.detail.startsAt,
      endsAt: row.detail.endsAt,
      transportationIncluded: row.detail.transportationIncluded,
      seatsOffered: row.detail.seatsOffered,
      creatorQuota: row.detail.creatorQuota,
      expectedDepositAmount: row.detail.expectedDepositAmount,
      normalSalesPrice: row.detail.normalSalesPrice,
      currency: row.detail.currency,
      acceptedAssignmentCount: accepted,
      pendingApplicationCount: pendingApps,
      agencyLegalName: _agencyLegalName(row.detail.agencyId),
      tourScope: row.detail.tourScope,
      requiresPassport: row.detail.requiresPassport,
      minimumPassportType: row.detail.minimumPassportType,
      requiresVisa: row.detail.requiresVisa,
      visaRequirementText: row.detail.visaRequirementText,
      requirements: row.detail.requirements,
    );
  }

  List<TourSummary> publishedTours() {
    final list =
        _tours.values
            .map((t) => _cloneTourDetail(t.detail))
            .where((t) => t.status == TourStatus.published)
            .toList()
          ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    return list;
  }

  bool isCreatorEligibleForTour({
    required String creatorId,
    required TourSummary tour,
  }) {
    final profile = creators[creatorId];
    if (profile == null) return false;
    return TourCreatorEligibility.isEligible(profile: profile, tour: tour);
  }

  List<TourSummary> publishedToursForCreator(String creatorId) {
    return publishedTours()
        .where((t) => isCreatorEligibleForTour(creatorId: creatorId, tour: t))
        .toList();
  }

  List<TourSummary> agencyTours(String agencyId) {
    return _tours.values
        .map((t) => _cloneTourDetail(t.detail))
        .where((t) => t.agencyId == agencyId)
        .toList();
  }

  bool hasCreatorApplied({required String tourId, required String creatorId}) {
    return _applications.any(
      (a) =>
          a.tourId == tourId &&
          a.creatorId == creatorId &&
          a.status != ApplicationStatus.withdrawn,
    );
  }

  List<ApplicationSummary> applicationsForCreator(String creatorId) {
    return _applications.where((a) => a.creatorId == creatorId).map((a) {
      final tour = _optionalTourSummary(a.tourId);
      return ApplicationSummary(
        id: a.id,
        tourId: a.tourId,
        status: a.status,
        message: a.message,
        tourTitle: tour?.title,
        agencyLegalName: tour?.agencyLegalName,
        suitabilityAue: a.scores.aue,
      );
    }).toList();
  }

  List<RatedApplication> ratedApplicantsForTour({
    required String actingAgencyId,
    required String tourId,
  }) {
    final tour = snapshotTourDetail(tourId);
    if (tour.agencyId != actingAgencyId) {
      throw AppException('Bu tur bu acente hesabına ait değil.');
    }

    final rows = _applications.where((a) => a.tourId == tourId).toList();

    return rows
        .map(
          (a) => RatedApplication(
            summary: ApplicationSummary(
              id: a.id,
              tourId: a.tourId,
              status: a.status,
              message: a.message,
              suitabilityAue: a.scores.aue,
            ),
            creator: creators[a.creatorId]!,
            scores: SuitabilityScores(
              aue: a.scores.aue,
              technicalFit: a.scores.technicalFit,
              publicationFit: a.scores.publicationFit,
              matchedRequirementCount: a.scores.matchedRequirementCount,
              totalRequirementCount: a.scores.totalRequirementCount,
              missingRequirementsText: a.scores.missingRequirementsText,
            ),
          ),
        )
        .toList();
  }

  Future<void> submitApplication({
    required String creatorId,
    required String tourId,
    required ApplicationCommitment commitment,
    required String? message,
  }) async {
    final tourRow = _tours[tourId];
    if (tourRow == null) throw AppException('Tur bulunamadı.');
    if (tourRow.detail.status != TourStatus.published) {
      throw AppException('Bu tura başvuru kapalı.');
    }
    if (!commitment.isComplete) {
      throw AppException('Başvuru öncesi tüm taahhütler işaretlenmelidir.');
    }
    if (hasCreatorApplied(tourId: tourId, creatorId: creatorId)) {
      throw AppException('Bu tur için zaten başvurunuz var.');
    }
    if (!tourRow.detail.isOpenForApplications) {
      throw AppException('Kota nedeniyle başvuru alınamıyor.');
    }

    TourPricingRules.validatePublishedTour(tourRow.detail);

    if (!isCreatorEligibleForTour(creatorId: creatorId, tour: tourRow.detail)) {
      throw const AppException(
        'Bu yurt dışı turu için pasaport/vize uygunluğunuz bulunmuyor.',
      );
    }

    final id = 'app-${DateTime.now().microsecondsSinceEpoch}';
    final reqCount = tourRow.detail.requirements.length;
    final totalReq = reqCount == 0 ? 1 : reqCount;
    final h = Object.hash(creatorId, tourId);
    final scores = SuitabilityScores(
      aue: 58 + (h.abs() % 35),
      technicalFit: 62 + ((h ~/ 3).abs() % 28),
      publicationFit: 60 + ((h ~/ 7).abs() % 30),
      matchedRequirementCount: reqCount.clamp(0, 10),
      totalRequirementCount: totalReq,
      missingRequirementsText: '',
    );

    final now = DateTime.now().toUtc();
    _applications.add(
      _ApplicationRow(
        id: id,
        tourId: tourId,
        creatorId: creatorId,
        status: ApplicationStatus.pendingReview,
        message: message,
        acceptedPublicationCommitment: commitment.acceptedPublicationCommitment,
        acceptedContentUsagePermission:
            commitment.acceptedContentUsagePermission,
        acceptedTourPriceClaimCondition:
            commitment.acceptedTourPriceClaimCondition,
        scores: scores,
        createdAt: now,
        updatedAt: now,
      ),
    );
    _refreshTourCounters(tourId);
  }

  Future<void> withdrawApplication({
    required String creatorId,
    required String applicationId,
  }) async {
    final row = _applications.firstWhere(
      (a) => a.id == applicationId,
      orElse: () => throw AppException('Başvuru bulunamadı.'),
    );
    if (row.creatorId != creatorId) {
      throw AppException('Bu başvuruyu geri çekemezsiniz.');
    }
    if (row.status != ApplicationStatus.pendingReview) {
      throw AppException('Yalnızca bekleyen başvuru geri çekilebilir.');
    }
    row.status = ApplicationStatus.withdrawn;
    row.updatedAt = DateTime.now().toUtc();
    _refreshTourCounters(row.tourId);
  }

  Future<void> agencySelectApplicant({
    required String actingAgencyId,
    required String tourId,
    required String applicationId,
  }) async {
    final tourRow = _tours[tourId];
    if (tourRow == null) {
      throw AppException('Tur bulunamadı.');
    }
    if (tourRow.detail.agencyId != actingAgencyId) {
      throw AppException('Bu turu yönetme yetkiniz yok.');
    }

    final tourDetail = snapshotTourDetail(tourId);
    final remainingSlots =
        (tourDetail.creatorQuota - tourDetail.acceptedAssignmentCount).clamp(
          0,
          tourDetail.creatorQuota,
        );
    if (remainingSlots <= 0) {
      throw AppException(
        'Bu tur için seçim kotası dolu; yeni başvuru seçilemez.',
      );
    }

    if (_assignments.any((a) => a.applicationId == applicationId)) {
      throw AppException('Bu başvuru için zaten bir atama oluşturuldu.');
    }

    final app = _applications.firstWhere(
      (a) => a.id == applicationId,
      orElse: () => throw AppException('Başvuru bulunamadı.'),
    );
    if (app.tourId != tourId) {
      throw AppException('Başvuru seçilen tura ait değil.');
    }
    if (app.status != ApplicationStatus.pendingReview) {
      throw AppException('Yalnızca incelemedeki başvuru seçilebilir.');
    }

    final now = DateTime.now().toUtc();
    app.status = ApplicationStatus.accepted;
    app.updatedAt = now;

    final assignmentId = 'asg-${app.id}';
    _assignments.add(
      _AssignmentRow(
        id: assignmentId,
        tourId: tourId,
        creatorId: app.creatorId,
        applicationId: app.id,
        status: AssignmentStatus.awaitingCreatorConfirmation,
        selectedAt: now,
        creatorDepositAcknowledgedAt: null,
        updatedAt: now,
      ),
    );

    _ensurePendingDepositForAssignment(assignmentId);

    _refreshTourCounters(tourId);
    final refreshed = snapshotTourDetail(tourId);
    if (refreshed.acceptedAssignmentCount >= refreshed.creatorQuota) {
      _closeTourApplications(tourId);
    }
  }

  Future<void> agencyAcceptApplicants({
    required String actingAgencyId,
    required String tourId,
    required List<String> applicationIds,
  }) async {
    if (applicationIds.isEmpty) return;
    final tourRow = _tours[tourId];
    if (tourRow == null) throw AppException('Tur bulunamadı.');
    if (tourRow.detail.agencyId != actingAgencyId) {
      throw AppException('Bu turu yönetme yetkiniz yok.');
    }

    final tourDetail = snapshotTourDetail(tourId);
    final remainingSlots =
        (tourDetail.creatorQuota - tourDetail.acceptedAssignmentCount).clamp(
          0,
          tourDetail.creatorQuota,
        );
    if (applicationIds.length > remainingSlots) {
      throw AppException(
        'Kota aşılıyor. En fazla $remainingSlots içerik üreticisi seçebilirsiniz.',
      );
    }

    final now = DateTime.now().toUtc();
    for (final applicationId in applicationIds) {
      final app = _applications.firstWhere(
        (a) => a.id == applicationId,
        orElse: () => throw AppException('Başvuru bulunamadı.'),
      );
      if (app.tourId != tourId) {
        throw AppException('Başvuru seçilen tura ait değil.');
      }
      if (app.status != ApplicationStatus.pendingReview) {
        throw AppException('Yalnızca bekleyen başvuru kabul edilebilir.');
      }

      app.status = ApplicationStatus.accepted;
      app.updatedAt = now;

      final assignmentId = 'asg-${app.id}';
      _assignments.add(
        _AssignmentRow(
          id: assignmentId,
          tourId: tourId,
          creatorId: app.creatorId,
          applicationId: app.id,
          status: AssignmentStatus.pendingDeposit,
          selectedAt: now,
          creatorDepositAcknowledgedAt: null,
          updatedAt: now,
        ),
      );

      depositsByAssignmentId[assignmentId] = MockDeposit(
        id: 'dep-$assignmentId',
        assignmentId: assignmentId,
        tourId: tourId,
        creatorId: app.creatorId,
        agencyId: tourDetail.agencyId,
        status: MockDepositStatus.pending,
        amountSnapshot: tourDetail.expectedDepositAmount,
      );

      deliveriesByAssignmentId[assignmentId] = ContentDelivery(
        id: 'delivery-$assignmentId',
        assignmentId: assignmentId,
        draftContentUrl: null,
        notes: null,
        status: ContentDeliveryStatus.waitingDraft,
        revisionCount: 0,
        submittedAt: null,
        approvedAt: null,
      );

      publicationsByAssignmentId[assignmentId] = PublicationRecord(
        id: 'pub-$assignmentId',
        assignmentId: assignmentId,
        platform: SocialPlatform.instagram,
        publishedUrl: null,
        status: PublicationStatus.waitingPublication,
        submittedAt: null,
        verifiedAt: null,
        monitoringStartDate: null,
        monitoringEndDate: null,
      );
    }

    _refreshTourCounters(tourId);
    final refreshed = snapshotTourDetail(tourId);
    if (refreshed.acceptedAssignmentCount >= refreshed.creatorQuota) {
      _closeTourApplications(tourId);
    }
  }

  void _closeTourApplications(String tourId) {
    final row = _tours[tourId];
    if (row == null) return;
    row.detail = TourDetail(
      id: row.detail.id,
      agencyId: row.detail.agencyId,
      title: row.detail.title,
      description: row.detail.description,
      departureCity: row.detail.departureCity,
      departureRegion: row.detail.departureRegion,
      destinationCluster: row.detail.destinationCluster,
      status: TourStatus.applicationClosed,
      startsAt: row.detail.startsAt,
      endsAt: row.detail.endsAt,
      transportationIncluded: row.detail.transportationIncluded,
      seatsOffered: row.detail.seatsOffered,
      creatorQuota: row.detail.creatorQuota,
      expectedDepositAmount: row.detail.expectedDepositAmount,
      normalSalesPrice: row.detail.normalSalesPrice,
      currency: row.detail.currency,
      acceptedAssignmentCount: row.detail.acceptedAssignmentCount,
      pendingApplicationCount: row.detail.pendingApplicationCount,
      agencyLegalName: _agencyLegalName(row.detail.agencyId),
      tourScope: row.detail.tourScope,
      requiresPassport: row.detail.requiresPassport,
      minimumPassportType: row.detail.minimumPassportType,
      requiresVisa: row.detail.requiresVisa,
      visaRequirementText: row.detail.visaRequirementText,
      requirements: row.detail.requirements,
    );

    for (final app in _applications) {
      if (app.tourId == tourId &&
          app.status == ApplicationStatus.pendingReview) {
        app.status = ApplicationStatus.rejected;
        app.updatedAt = DateTime.now().toUtc();
      }
    }
    _refreshTourCounters(tourId);
  }

  _AssignmentRow _assignmentOrThrow(String assignmentId) {
    return _assignments.firstWhere(
      (a) => a.id == assignmentId,
      orElse: () => throw AppException('Atama bulunamadı.'),
    );
  }

  AssignmentSummary _assignmentSummaryFromRow(_AssignmentRow row) {
    final tour = snapshotTourSummary(row.tourId);
    final deposit = depositsByAssignmentId[row.id];
    return AssignmentSummary(
      id: row.id,
      tourId: row.tourId,
      applicationId: row.applicationId,
      status: row.status,
      tourTitle: tour.title,
      agencyLegalName: tour.agencyLegalName,
      depositStatus: deposit?.status,
    );
  }

  String? _applicationMessage(String applicationId) {
    for (final a in _applications) {
      if (a.id == applicationId) {
        return a.message;
      }
    }
    return null;
  }

  /// Aşama 2.7 — seçim sonrası kesin onay bekleyen atamalarda mock depozito yoksa oluşturur.
  void _ensurePendingDepositForAssignment(String assignmentId) {
    final row = _assignmentOrThrow(assignmentId);
    if (row.status != AssignmentStatus.awaitingCreatorConfirmation) {
      return;
    }
    if (depositsByAssignmentId.containsKey(assignmentId)) {
      return;
    }
    final tourDetail = snapshotTourDetail(row.tourId);
    depositsByAssignmentId[assignmentId] = MockDeposit(
      id: 'dep-$assignmentId',
      assignmentId: assignmentId,
      tourId: row.tourId,
      creatorId: row.creatorId,
      agencyId: tourDetail.agencyId,
      status: MockDepositStatus.pending,
      amountSnapshot: tourDetail.expectedDepositAmount,
    );
  }

  AssignmentDetail assignmentDetailForViewer({
    required String assignmentId,
    required String? viewerCreatorId,
    required String? viewerAgencyId,
  }) {
    final row = _assignmentOrThrow(assignmentId);
    final tour = snapshotTourSummary(row.tourId);
    if (viewerCreatorId != null && row.creatorId != viewerCreatorId) {
      throw AppException('Bu atamayı görüntüleyemezsiniz.');
    }
    if (viewerAgencyId != null && tour.agencyId != viewerAgencyId) {
      throw AppException('Bu atamayı görüntüleme yetkiniz yok.');
    }

    if (row.status == AssignmentStatus.awaitingCreatorConfirmation) {
      _ensurePendingDepositForAssignment(assignmentId);
    }

    final deposit = depositsByAssignmentId[assignmentId];
    final delivery = deliveriesByAssignmentId[assignmentId];
    final publication = publicationsByAssignmentId[assignmentId];

    return AssignmentDetail(
      summary: _assignmentSummaryFromRow(row),
      tour: tour,
      deposit: deposit,
      delivery: delivery,
      publication: publication,
      creatorDepositAcknowledgedAt: row.creatorDepositAcknowledgedAt,
      applicationMessage: _applicationMessage(row.applicationId),
    );
  }

  List<AssignmentSummary> assignmentsForCreator(String creatorId) {
    return _assignments
        .where((a) => a.creatorId == creatorId)
        .map(_assignmentSummaryFromRow)
        .toList();
  }

  List<AssignmentSummary> assignmentsForAgencyTour({
    required String agencyId,
    required String tourId,
  }) {
    final tour = snapshotTourSummary(tourId);
    if (tour.agencyId != agencyId) {
      throw AppException('Tur bu acente hesabına ait değil.');
    }
    return _assignments
        .where((a) => a.tourId == tourId)
        .map(_assignmentSummaryFromRow)
        .toList();
  }

  Future<void> creatorConfirmDeposit({
    required String assignmentId,
    required String creatorId,
    required ApplicationCommitment commitment,
  }) async {
    if (!commitment.isComplete) {
      throw AppException('Depozito öncesi taahhütler tekrar onaylanmalıdır.');
    }
    final row = _assignmentOrThrow(assignmentId);
    if (row.creatorId != creatorId) {
      throw AppException('Bu atama sizin hesabınıza ait değil.');
    }

    final now = DateTime.now().toUtc();

    if (row.status == AssignmentStatus.awaitingCreatorConfirmation) {
      _ensurePendingDepositForAssignment(assignmentId);
      final deposit = depositsByAssignmentId[assignmentId]!;
      if (deposit.status != MockDepositStatus.pending) {
        throw AppException('Mock depozito bu aşamada zaten işlendi.');
      }
      row.status = AssignmentStatus.active;
      row.creatorDepositAcknowledgedAt = now;
      row.updatedAt = now;
      depositsByAssignmentId[assignmentId] = MockDeposit(
        id: deposit.id,
        assignmentId: deposit.assignmentId,
        tourId: deposit.tourId,
        creatorId: deposit.creatorId,
        agencyId: deposit.agencyId,
        status: MockDepositStatus.held,
        amountSnapshot: deposit.amountSnapshot,
      );
      return;
    }

    if (row.status == AssignmentStatus.pendingDeposit) {
      final deposit = depositsByAssignmentId[assignmentId]!;
      if (deposit.status != MockDepositStatus.pending) {
        throw AppException('Mock depozito durumu onay için uygun değil.');
      }
      row.status = AssignmentStatus.waitingContentDraft;
      row.creatorDepositAcknowledgedAt = now;
      row.updatedAt = now;
      depositsByAssignmentId[assignmentId] = MockDeposit(
        id: deposit.id,
        assignmentId: deposit.assignmentId,
        tourId: deposit.tourId,
        creatorId: deposit.creatorId,
        agencyId: deposit.agencyId,
        status: MockDepositStatus.held,
        amountSnapshot: deposit.amountSnapshot,
      );
      return;
    }

    throw AppException('Depozito onayı bu aşamada beklenmiyor.');
  }

  ContentDelivery? deliverySnapshot(String assignmentId) {
    final delivery = deliveriesByAssignmentId[assignmentId];
    if (delivery == null) return null;
    return ContentDelivery(
      id: delivery.id,
      assignmentId: delivery.assignmentId,
      draftContentUrl: delivery.draftContentUrl,
      notes: delivery.notes,
      status: delivery.status,
      revisionCount: delivery.revisionCount,
      submittedAt: delivery.submittedAt,
      approvedAt: delivery.approvedAt,
    );
  }

  PublicationRecord? publicationSnapshot(String assignmentId) {
    final pub = publicationsByAssignmentId[assignmentId];
    if (pub == null) return null;
    return PublicationRecord(
      id: pub.id,
      assignmentId: pub.assignmentId,
      platform: pub.platform,
      publishedUrl: pub.publishedUrl,
      status: pub.status,
      submittedAt: pub.submittedAt,
      verifiedAt: pub.verifiedAt,
      monitoringStartDate: pub.monitoringStartDate,
      monitoringEndDate: pub.monitoringEndDate,
    );
  }

  Future<void> submitDraftUrl({
    required String assignmentId,
    required String creatorId,
    required String url,
    String? notes,
  }) async {
    final row = _assignmentOrThrow(assignmentId);
    if (row.creatorId != creatorId) {
      throw AppException('Bu teslim sizin hesabınıza ait değil.');
    }
    if (row.status != AssignmentStatus.waitingContentDraft &&
        row.status != AssignmentStatus.revisionRequested) {
      throw AppException('Taslak gönderimi bu aşamada beklenmiyor.');
    }

    final existing = deliveriesByAssignmentId[assignmentId]!;
    deliveriesByAssignmentId[assignmentId] = ContentDelivery(
      id: existing.id,
      assignmentId: existing.assignmentId,
      draftContentUrl: url,
      notes: notes ?? existing.notes,
      status: ContentDeliveryStatus.draftSubmitted,
      revisionCount: existing.revisionCount,
      submittedAt: DateTime.now().toUtc(),
      approvedAt: null,
    );

    row.status = AssignmentStatus.waitingAgencyApproval;
    row.updatedAt = DateTime.now().toUtc();
  }

  Future<void> agencyApproveDraft({
    required String assignmentId,
    required String actingAgencyId,
  }) async {
    assignmentDetailForViewer(
      assignmentId: assignmentId,
      viewerCreatorId: null,
      viewerAgencyId: actingAgencyId,
    );
    final row = _assignmentOrThrow(assignmentId);
    if (row.status != AssignmentStatus.waitingAgencyApproval) {
      throw AppException('Taslak onayı beklenmiyor.');
    }

    final existing = deliveriesByAssignmentId[assignmentId]!;
    deliveriesByAssignmentId[assignmentId] = ContentDelivery(
      id: existing.id,
      assignmentId: existing.assignmentId,
      draftContentUrl: existing.draftContentUrl,
      notes: existing.notes,
      status: ContentDeliveryStatus.approvedForPublication,
      revisionCount: existing.revisionCount,
      submittedAt: existing.submittedAt,
      approvedAt: DateTime.now().toUtc(),
    );

    row.status = AssignmentStatus.waitingPublication;
    row.updatedAt = DateTime.now().toUtc();
  }

  Future<void> agencyRequestRevision({
    required String assignmentId,
    required String actingAgencyId,
    required String checklistNotes,
  }) async {
    assignmentDetailForViewer(
      assignmentId: assignmentId,
      viewerCreatorId: null,
      viewerAgencyId: actingAgencyId,
    );
    final assignmentRow = _assignmentOrThrow(assignmentId);
    if (assignmentRow.status != AssignmentStatus.waitingAgencyApproval) {
      throw AppException('Revizyon talebi uygun bir aşamada değil.');
    }

    final existing = deliveriesByAssignmentId[assignmentId]!;
    if (existing.revisionCount >= 1) {
      throw AppException(
        'MVP kuralına göre teknik revizyon hakkınız kullanılmış durumda.',
      );
    }

    deliveriesByAssignmentId[assignmentId] = ContentDelivery(
      id: existing.id,
      assignmentId: existing.assignmentId,
      draftContentUrl: existing.draftContentUrl,
      notes: checklistNotes,
      status: ContentDeliveryStatus.revisionRequested,
      revisionCount: existing.revisionCount + 1,
      submittedAt: existing.submittedAt,
      approvedAt: null,
    );

    assignmentRow.status = AssignmentStatus.revisionRequested;
    assignmentRow.updatedAt = DateTime.now().toUtc();
  }

  Future<void> submitPublicationUrl({
    required String assignmentId,
    required String creatorId,
    required String url,
  }) async {
    final row = _assignmentOrThrow(assignmentId);
    if (row.creatorId != creatorId) {
      throw AppException('Bu yayın bildirimi sizin hesabınıza ait değil.');
    }
    if (row.status != AssignmentStatus.waitingPublication) {
      throw AppException('Yayın URL’si bu aşamada beklenmiyor.');
    }

    final existing = publicationsByAssignmentId[assignmentId]!;
    publicationsByAssignmentId[assignmentId] = PublicationRecord(
      id: existing.id,
      assignmentId: existing.assignmentId,
      platform: existing.platform,
      publishedUrl: url,
      status: PublicationStatus.linkSubmitted,
      submittedAt: DateTime.now().toUtc(),
      verifiedAt: null,
      monitoringStartDate: null,
      monitoringEndDate: null,
    );

    row.status = AssignmentStatus.publicationSubmitted;
    row.updatedAt = DateTime.now().toUtc();
  }

  Future<void> agencyVerifyPublication({
    required String assignmentId,
    required String actingAgencyId,
  }) async {
    assignmentDetailForViewer(
      assignmentId: assignmentId,
      viewerCreatorId: null,
      viewerAgencyId: actingAgencyId,
    );
    final row = _assignmentOrThrow(assignmentId);
    if (row.status != AssignmentStatus.publicationSubmitted) {
      throw AppException('Yayın doğrulaması beklenmiyor.');
    }

    final publication = publicationsByAssignmentId[assignmentId]!;
    final verifiedAt = DateTime.now().toUtc();
    final start = verifiedAt.toUtc().add(const Duration(days: 1));
    publicationsByAssignmentId[assignmentId] = PublicationRecord(
      id: publication.id,
      assignmentId: publication.assignmentId,
      platform: publication.platform,
      publishedUrl: publication.publishedUrl,
      status: PublicationStatus.monitoring30Days,
      submittedAt: publication.submittedAt,
      verifiedAt: verifiedAt,
      monitoringStartDate: start,
      monitoringEndDate: start.add(const Duration(days: 30)),
    );

    final deposit = depositsByAssignmentId[assignmentId]!;
    depositsByAssignmentId[assignmentId] = MockDeposit(
      id: deposit.id,
      assignmentId: deposit.assignmentId,
      tourId: deposit.tourId,
      creatorId: deposit.creatorId,
      agencyId: deposit.agencyId,
      status: MockDepositStatus.releasedAfterPublication,
      amountSnapshot: deposit.amountSnapshot,
    );

    row.status = AssignmentStatus.under30DayMonitoring;
    row.updatedAt = verifiedAt;
  }

  Future<void> agencyReportViolation({
    required String actingAgencyId,
    required String assignmentId,
    required String publicationId,
    required String reason,
    String? evidenceUrl,
  }) async {
    final publication = publicationsByAssignmentId[assignmentId];
    if (publication == null) {
      throw AppException('Yayın kaydı bulunamadı.');
    }
    if (publication.id != publicationId) {
      throw AppException('Yayın kimliği eşleşmiyor.');
    }

    final tourSnapshot = snapshotTourSummary(
      _assignmentOrThrow(assignmentId).tourId,
    );
    if (tourSnapshot.agencyId != actingAgencyId) {
      throw AppException('Bu ihlali bildirmek için yetkiniz yok.');
    }

    final now = DateTime.now().toUtc();
    violations.add(
      ViolationReport(
        id: 'vio-${now.microsecondsSinceEpoch}',
        assignmentId: assignmentId,
        publicationId: publicationId,
        reportedByAgencyId: actingAgencyId,
        reason: reason,
        evidenceUrl: evidenceUrl,
        status: ViolationReportStatus.open,
        createdAt: now,
        resolvedAt: null,
      ),
    );

    final row = _assignmentOrThrow(assignmentId);
    row.status = AssignmentStatus.violationReported;
    row.updatedAt = now;
  }

  List<ViolationReport> violationsForAdmin() {
    return List<ViolationReport>.from(violations);
  }

  int pendingApplicationsForAgency(String agencyId) {
    final tourIds = _tours.entries
        .where((entry) => entry.value.detail.agencyId == agencyId)
        .map((entry) => entry.key)
        .toSet();

    return _applications.where((app) {
      return tourIds.contains(app.tourId) &&
          app.status == ApplicationStatus.pendingReview;
    }).length;
  }

  int pendingApplicationsForCreator(String creatorId) {
    return _applications
        .where(
          (app) =>
              app.creatorId == creatorId &&
              app.status == ApplicationStatus.pendingReview,
        )
        .length;
  }

  int creatorActionableAssignments(String creatorId) {
    const actionable = <AssignmentStatus>{
      AssignmentStatus.pendingDeposit,
      AssignmentStatus.waitingContentDraft,
      AssignmentStatus.revisionRequested,
      AssignmentStatus.waitingAgencyApproval,
      AssignmentStatus.waitingPublication,
      AssignmentStatus.publicationSubmitted,
    };
    return _assignments
        .where(
          (assignment) =>
              assignment.creatorId == creatorId &&
              actionable.contains(assignment.status),
        )
        .length;
  }

  Future<void> adminResolveViolation({
    required String violationId,
    required String resolutionNote,
    required bool confirmViolation,
  }) async {
    final match = violations.firstWhere(
      (v) => v.id == violationId,
      orElse: () => throw AppException('İhlal kaydı bulunamadı.'),
    );

    final index = violations.indexOf(match);
    violations[index] = ViolationReport(
      id: match.id,
      assignmentId: match.assignmentId,
      publicationId: match.publicationId,
      reportedByAgencyId: match.reportedByAgencyId,
      reason: '$resolutionNote\n${match.reason}',
      evidenceUrl: match.evidenceUrl,
      status: confirmViolation
          ? ViolationReportStatus.confirmed
          : ViolationReportStatus.rejected,
      createdAt: match.createdAt,
      resolvedAt: DateTime.now().toUtc(),
    );
  }

  List<PendingAgencyReview> pendingAgencyApprovals() {
    return _agencies.values
        .where((a) => a.status == AgencyStatus.pendingApproval)
        .map(
          (a) => PendingAgencyReview(
            id: a.id,
            legalName: a.legalName,
            status: a.status,
          ),
        )
        .toList();
  }

  Future<void> adminSetAgencyApproval({
    required String agencyId,
    required bool approved,
  }) async {
    final agency = _agencies[agencyId];
    if (agency == null) {
      throw AppException('Acente bulunamadı.');
    }
    agency.status = approved ? AgencyStatus.approved : AgencyStatus.rejected;
  }

  List<AssignmentTimelineStep> buildTimeline(String assignmentId) {
    final row = _assignmentOrThrow(assignmentId);
    final deposit = depositsByAssignmentId[assignmentId];
    final delivery = deliveriesByAssignmentId[assignmentId];
    final publication = publicationsByAssignmentId[assignmentId];

    if (publication == null) {
      if (deposit == null) {
        return [
          AssignmentTimelineStep(
            phase: AssignmentTimelinePhase.awaitingCreatorConfirmation,
            label: 'Üretici kesin onayı ve mock depozito (PENDING→HELD)',
            isComplete: false,
            timestamp: row.selectedAt,
          ),
        ];
      }
      final confirmationComplete =
          row.creatorDepositAcknowledgedAt != null &&
          deposit.status == MockDepositStatus.held;
      return [
        AssignmentTimelineStep(
          phase: AssignmentTimelinePhase.awaitingCreatorConfirmation,
          label: 'Üretici kesin onayı ve mock depozito (PENDING→HELD)',
          isComplete: confirmationComplete,
          timestamp: row.creatorDepositAcknowledgedAt ?? row.selectedAt,
        ),
      ];
    }

    bool draftComplete =
        delivery != null &&
        delivery.status != ContentDeliveryStatus.waitingDraft;
    bool agencyReviewComplete =
        delivery != null &&
        (delivery.status == ContentDeliveryStatus.approvedForPublication ||
            delivery.status == ContentDeliveryStatus.revisionRequested);
    bool publicationComplete = publication.publishedUrl != null;
    bool released =
        deposit?.status == MockDepositStatus.releasedAfterPublication;

    return [
      AssignmentTimelineStep(
        phase: AssignmentTimelinePhase.awaitingDepositConfirmation,
        label: 'Depozito / taahhüt onayı',
        isComplete: row.creatorDepositAcknowledgedAt != null,
        timestamp: row.creatorDepositAcknowledgedAt,
      ),
      AssignmentTimelineStep(
        phase: AssignmentTimelinePhase.waitingDraftSubmission,
        label: 'Taslak URL gönderimi',
        isComplete: draftComplete,
        timestamp: delivery?.submittedAt,
      ),
      AssignmentTimelineStep(
        phase: AssignmentTimelinePhase.waitingAgencyReview,
        label: 'Acente teknik kontrol',
        isComplete: agencyReviewComplete,
        timestamp: delivery?.approvedAt,
      ),
      AssignmentTimelineStep(
        phase: AssignmentTimelinePhase.awaitingPublicationSubmission,
        label: 'Yayın URL bildirimi',
        isComplete: publicationComplete,
        timestamp: publication.submittedAt,
      ),
      AssignmentTimelineStep(
        phase: AssignmentTimelinePhase.depositReleased,
        label: 'Mock depozito serbest bırakma',
        isComplete: released,
        timestamp: publication.verifiedAt,
      ),
      AssignmentTimelineStep(
        phase: AssignmentTimelinePhase.monitoring30Days,
        label: '30 günlük izleme penceresi',
        isComplete:
            publication.status == PublicationStatus.monitoring30Days ||
            publication.status == PublicationStatus.completed30Days,
        timestamp: publication.monitoringStartDate,
      ),
    ];
  }
}
