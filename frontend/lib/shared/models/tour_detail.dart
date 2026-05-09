import 'tour_requirement_type.dart';
import 'tour_summary.dart';

/// Detay yüzünde gereksinim listesi dahil.
class TourDetail extends TourSummary {
  const TourDetail({
    required super.id,
    required super.agencyId,
    required super.title,
    required super.description,
    required super.departureCity,
    required super.departureRegion,
    required super.destinationCluster,
    required super.status,
    required super.startsAt,
    required super.endsAt,
    required super.transportationIncluded,
    required super.seatsOffered,
    required super.creatorQuota,
    required super.expectedDepositAmount,
    required super.normalSalesPrice,
    super.currency,
    required super.acceptedAssignmentCount,
    required super.pendingApplicationCount,
    super.agencyLegalName,
    super.tourScope,
    super.requiresPassport,
    super.minimumPassportType,
    super.requiresVisa,
    super.visaRequirementText,
    required this.requirements,
  });

  final List<TourRequirementType> requirements;
}
