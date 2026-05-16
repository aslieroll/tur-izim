import 'package:tur_izim/shared/models/application_status.dart';
import 'package:tur_izim/shared/models/application_summary.dart';
import 'package:tur_izim/shared/models/assignment_status.dart';
import 'package:tur_izim/shared/models/assignment_summary.dart';
import 'package:tur_izim/shared/models/creator_profile.dart';
import 'package:tur_izim/shared/models/departure_region.dart';
import 'package:tur_izim/shared/models/destination_cluster.dart';
import 'package:tur_izim/shared/models/mock_deposit.dart';
import 'package:tur_izim/shared/models/mock_deposit_status.dart';
import 'package:tur_izim/shared/models/passport_type.dart';
import 'package:tur_izim/shared/models/publication_record.dart';
import 'package:tur_izim/shared/models/publication_status.dart';
import 'package:tur_izim/shared/models/social_platform.dart';
import 'package:tur_izim/shared/models/rated_application.dart';
import 'package:tur_izim/shared/models/suitability_scores.dart';
import 'package:tur_izim/shared/models/tour_detail.dart';
import 'package:tur_izim/shared/models/tour_requirement_type.dart';
import 'package:tur_izim/shared/models/tour_scope.dart';
import 'package:tur_izim/shared/models/tour_status.dart';
import 'package:tur_izim/shared/models/tour_summary.dart';
import 'package:tur_izim/shared/models/visa_eligibility_status.dart';

double? _asDouble(Object? v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

int _asInt(Object? v, [int fallback = 0]) {
  if (v == null) return fallback;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? fallback;
}

DateTime _parseInstant(String? s) {
  if (s == null || s.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  return DateTime.parse(s);
}

DateTime _parseLocalDate(String? s) {
  if (s == null || s.isEmpty) {
    return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }
  return DateTime.parse(s);
}

TourScope _parseTourScope(String? raw) {
  if (raw == 'INTERNATIONAL') return TourScope.international;
  return TourScope.domestic;
}

TourStatus _parseTourStatus(String? raw) {
  return switch (raw) {
    'PUBLISHED' => TourStatus.published,
    'CLOSED' => TourStatus.applicationClosed,
    'CANCELLED' => TourStatus.cancelled,
    _ => TourStatus.draft,
  };
}

PassportType _parsePassportType(String? raw) {
  return switch (raw) {
    'NONE' => PassportType.none,
    'TURKISH_ORDINARY' => PassportType.bordo,
    'OTHER' => PassportType.bordo,
    'TURKISH_SPECIAL' => PassportType.yesil,
    'TURKISH_SERVICE' => PassportType.gri,
    'TURKISH_DIPLOMATIC' => PassportType.siyah,
    _ => PassportType.none,
  };
}

ApplicationStatus _parseApplicationStatus(String? raw) {
  return switch (raw) {
    'PENDING_REVIEW' => ApplicationStatus.pendingReview,
    'SELECTED' => ApplicationStatus.agencySelected,
    'REJECTED' => ApplicationStatus.rejected,
    'CANCELLED' => ApplicationStatus.withdrawn,
    _ => ApplicationStatus.pendingReview,
  };
}

AssignmentStatus _parseAssignmentStatus(String? raw) {
  return switch (raw) {
    'PENDING_CREATOR_CONFIRMATION' => AssignmentStatus.awaitingCreatorConfirmation,
    'CONFIRMED' => AssignmentStatus.pendingDeposit,
    'COMPLETED' => AssignmentStatus.completed,
    'CANCELLED' => AssignmentStatus.cancelled,
    _ => AssignmentStatus.awaitingCreatorConfirmation,
  };
}

MockDepositStatus _parseDepositStatus(String? raw) {
  return switch (raw) {
    'PENDING' => MockDepositStatus.pending,
    'HELD' => MockDepositStatus.held,
    'RELEASED' => MockDepositStatus.releasedAfterPublication,
    'CLAIMED_BY_AGENCY' => MockDepositStatus.forfeited,
    'CANCELLED' => MockDepositStatus.forfeited,
    _ => MockDepositStatus.pending,
  };
}

DepartureRegion _inferDepartureRegion(String city) {
  final c = city.toLowerCase();
  if (c.contains('adana')) return DepartureRegion.adana;
  if (c.contains('mersin')) return DepartureRegion.mersin;
  if (c.contains('gaziantep')) return DepartureRegion.gaziantep;
  if (c.contains('hatay')) return DepartureRegion.hatay;
  if (c.contains('konya')) return DepartureRegion.konya;
  if (c.contains('kayseri') || c.contains('nevşehir')) return DepartureRegion.kayseri;
  return DepartureRegion.adana;
}

DestinationCluster _inferDestinationCluster(String destination) {
  final d = destination.toLowerCase();
  if (d.contains('kapadokya') || d.contains('nevşehir')) {
    return DestinationCluster.kapadokya;
  }
  return DestinationCluster.guney;
}

/// `passportVisaSummary` + `tourType` ile MVP uyumlu bayraklar.
({bool requiresPassport, bool requiresVisa, String? visaText}) _inferTravelGates(
  TourScope scope,
  String summary,
) {
  if (scope == TourScope.domestic) {
    return (requiresPassport: false, requiresVisa: false, visaText: null);
  }
  final rp = summary.contains('Pasaport gerekli');
  final rv = summary.contains('Vize gerekli');
  String? visaText;
  if (rv) {
    final i = summary.indexOf('Vize gerekli');
    if (i >= 0) {
      visaText = summary.substring(i).trim();
    }
  }
  return (requiresPassport: rp, requiresVisa: rv, visaText: visaText);
}

TourSummary tourSummaryFromBackendJson(Map<String, dynamic> j) {
  final scope = _parseTourScope(j['tourType']?.toString());
  final summaryText = j['passportVisaSummary']?.toString() ?? '';
  final gates = _inferTravelGates(scope, summaryText);
  final dest = j['destination']?.toString() ?? '';
  final depCity = j['departureCity']?.toString() ?? '';
  final seats = _asInt(j['availableCreatorSeats'], 0);

  PassportType minPass = PassportType.bordo;
  final minRaw = RegExp(r'min:\s*([A-Z_]+)').firstMatch(summaryText);
  if (minRaw != null) {
    minPass = _parsePassportType(minRaw.group(1));
  }

  return TourSummary(
    id: j['id'].toString(),
    agencyId: j['agencyId'].toString(),
    title: j['title']?.toString() ?? '',
    description: j['description']?.toString() ?? '',
    departureCity: depCity,
    departureRegion: _inferDepartureRegion(depCity),
    destinationCity: dest,
    destinationCluster: _inferDestinationCluster(dest),
    status: _parseTourStatus(j['status']?.toString()),
    startsAt: _parseLocalDate(j['startDate']?.toString()),
    endsAt: _parseLocalDate(j['endDate']?.toString()),
    transportationIncluded: true,
    seatsOffered: seats,
    creatorQuota: seats,
    expectedDepositAmount: _asDouble(j['expectedDepositAmount']) ?? 0,
    normalSalesPrice: _asDouble(j['normalSalePrice']) ?? 0,
    acceptedAssignmentCount: 0,
    pendingApplicationCount: 0,
    agencyLegalName: j['agencyName']?.toString(),
    tourScope: scope,
    requiresPassport: gates.requiresPassport,
    minimumPassportType: minPass,
    requiresVisa: gates.requiresVisa,
    visaRequirementText: gates.visaText,
  );
}

TourDetail tourDetailFromBackendTourJson(Map<String, dynamic> j) {
  final base = tourSummaryFromBackendJson(j);
  return TourDetail(
    id: base.id,
    agencyId: base.agencyId,
    title: base.title,
    description: base.description,
    departureCity: base.departureCity,
    departureRegion: base.departureRegion,
    destinationCity: base.destinationCity,
    destinationCluster: base.destinationCluster,
    status: base.status,
    startsAt: base.startsAt,
    endsAt: base.endsAt,
    transportationIncluded: base.transportationIncluded,
    seatsOffered: base.seatsOffered,
    creatorQuota: base.creatorQuota,
    expectedDepositAmount: base.expectedDepositAmount,
    normalSalesPrice: base.normalSalesPrice,
    acceptedAssignmentCount: base.acceptedAssignmentCount,
    pendingApplicationCount: base.pendingApplicationCount,
    agencyLegalName: base.agencyLegalName,
    tourScope: base.tourScope,
    requiresPassport: base.requiresPassport,
    minimumPassportType: base.minimumPassportType,
    requiresVisa: base.requiresVisa,
    visaRequirementText: base.visaRequirementText,
    requirements: const [TourRequirementType.thirtyDaysPublicationRequired],
  );
}

ApplicationSummary applicationSummaryFromBackendJson(Map<String, dynamic> j) {
  final aue = _asDouble(j['suitabilityScore']);
  return ApplicationSummary(
    id: j['id'].toString(),
    tourId: j['tourId'].toString(),
    status: _parseApplicationStatus(j['status']?.toString()),
    message: j['applicationNote']?.toString(),
    tourTitle: j['tourTitle']?.toString(),
    suitabilityAue: aue,
  );
}

AssignmentSummary assignmentSummaryFromListJson(Map<String, dynamic> j) {
  final dep = j['deposit'] is Map<String, dynamic> ? j['deposit'] as Map<String, dynamic> : null;
  return AssignmentSummary(
    id: j['id'].toString(),
    tourId: j['tourId'].toString(),
    applicationId: j['applicationId'].toString(),
    status: _parseAssignmentStatus(j['status']?.toString()),
    tourTitle: j['tourTitle']?.toString(),
    agencyLegalName: j['agencyName']?.toString(),
    depositStatus: dep != null ? _parseDepositStatus(dep['status']?.toString()) : null,
  );
}

MockDeposit? mockDepositFromEmbeddedJson(
  Map<String, dynamic> assignmentJson,
  String assignmentId,
  String tourId,
  String creatorId,
  String agencyId,
) {
  final dep = assignmentJson['deposit'];
  if (dep is! Map<String, dynamic>) return null;
  return MockDeposit(
    id: dep['id'].toString(),
    assignmentId: assignmentId,
    tourId: tourId,
    creatorId: creatorId,
    agencyId: agencyId,
    status: _parseDepositStatus(dep['status']?.toString()),
    amountSnapshot: _asDouble(dep['amount']) ?? 0,
  );
}

CreatorProfile creatorProfileFromBackendJson(Map<String, dynamic> j) {
  final visaOk = j['hasSchengenVisa'] == true ||
      j['hasUsVisa'] == true ||
      j['hasUkVisa'] == true ||
      j['hasOtherValidVisa'] == true;
  return CreatorProfile(
    id: j['id'].toString(),
    displayName: j['fullName']?.toString() ?? 'Üretici',
    instagramUrl: null,
    tiktokUrl: null,
    youtubeUrl: null,
    portfolioUrl: null,
    hasPublicInstagram: false,
    hasPublicTiktok: false,
    canCreateVerticalVideo: false,
    canShootPhotos: true,
    canDeliverRawFiles: false,
    hasBasicEditingSkill: false,
    hasTravelVlogExperience: false,
    canRecord1080pVideo: false,
    passportType: _parsePassportType(j['passportType']?.toString()),
    hasValidPassport: j['hasValidPassport'] == true,
    visaEligibility: visaOk ? VisaEligibilityStatus.hasRequiredVisa : VisaEligibilityStatus.none,
    universityName: j['universityName']?.toString(),
    campusCity: j['city']?.toString(),
  );
}

SuitabilityScores suitabilityScoresFromAue(double? aue) {
  final v = aue ?? 0;
  return SuitabilityScores(
    aue: v,
    technicalFit: v,
    publicationFit: v,
    matchedRequirementCount: 0,
    totalRequirementCount: 0,
    missingRequirementsText: '',
  );
}

RatedApplication ratedApplicationFromBackendRow(
  Map<String, dynamic> appJson,
  CreatorProfile creator,
) {
  final summary = applicationSummaryFromBackendJson(appJson);
  final scores = suitabilityScoresFromAue(_asDouble(appJson['suitabilityScore']));
  return RatedApplication(summary: summary, creator: creator, scores: scores);
}

PublicationStatus _parsePublicationStatus(String? raw) {
  return switch (raw) {
    'SUBMITTED' => PublicationStatus.linkSubmitted,
    'APPROVED' => PublicationStatus.verified,
    'REJECTED' => PublicationStatus.removalReported,
    'VIOLATION_REPORTED' => PublicationStatus.violationConfirmed,
    _ => PublicationStatus.waitingPublication,
  };
}

PublicationRecord? publicationRecordFromBackendJson(Map<String, dynamic> j, String assignmentId) {
  final id = j['id']?.toString();
  if (id == null) return null;
  final url = j['postUrl']?.toString();
  final submitted = j['submittedAt']?.toString();
  return PublicationRecord(
    id: id,
    assignmentId: assignmentId,
    platform: SocialPlatform.other,
    publishedUrl: url?.isEmpty == true ? null : url,
    status: _parsePublicationStatus(j['status']?.toString()),
    submittedAt: submitted != null ? _parseInstant(submitted) : null,
    verifiedAt: null,
    monitoringStartDate: j['publicationDeadline'] != null
        ? _parseInstant(j['publicationDeadline']?.toString())
        : null,
    monitoringEndDate: j['mustStayPublicUntil'] != null
        ? _parseInstant(j['mustStayPublicUntil']?.toString())
        : null,
  );
}