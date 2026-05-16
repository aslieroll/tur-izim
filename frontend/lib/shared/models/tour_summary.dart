import 'destination_cluster.dart';
import 'departure_region.dart';
import 'passport_type.dart';
import 'tour_scope.dart';
import 'tour_status.dart';

/// List row for tours (ilanlar / acente listeleri).
class TourSummary {
  const TourSummary({
    required this.id,
    required this.agencyId,
    required this.title,
    required this.description,
    required this.departureCity,
    required this.departureRegion,
    this.destinationCity,
    required this.destinationCluster,
    this.routeSummary,
    required this.status,
    required this.startsAt,
    required this.endsAt,
    required this.transportationIncluded,
    required this.seatsOffered,
    required this.creatorQuota,
    required this.expectedDepositAmount,
    required this.normalSalesPrice,
    this.currency = 'TRY',
    required this.acceptedAssignmentCount,
    required this.pendingApplicationCount,
    this.agencyLegalName,
    /// Acentenin beyan ettiği faaliyet şehri (MVP’de tek şehir).
    this.agencyOperatingCity,
    this.tourScope = TourScope.domestic,
    this.requiresPassport = false,
    this.minimumPassportType = PassportType.none,
    this.requiresVisa = false,
    this.visaRequirementText,
    this.imageAssetPath,
    this.visualKey,
  });

  final String id;
  final String agencyId;
  final String title;
  final String description;

  /// Mock / API: acente görünen adı (liste kartları için).
  final String? agencyLegalName;

  /// Acente profilinden gelen işletildiği şehir beyanı (opsiyonel mock).
  final String? agencyOperatingCity;

  final String departureCity;
  final DepartureRegion departureRegion;

  /// Beyana dayalı varış şehri veya bağlantılı nokta (opsiyonel).
  final String? destinationCity;
  final DestinationCluster destinationCluster;

  /// Liste/detay için isteğe bağlı tek satır rota özeti.
  final String? routeSummary;
  final TourStatus status;
  final DateTime startsAt;
  final DateTime endsAt;
  final bool transportationIncluded;
  final int seatsOffered;

  /// `tours.creator_quota`
  final int creatorQuota;

  /// Acentenin ilanladığı turun normal satış fiyatı (bilgilendirme).
  final double normalSalesPrice;

  /// Üreticinin öngördüğü mock depozito tutarı (bilgilendirme; gerçek ödeme yok).
  final double expectedDepositAmount;

  /// Örn. `TRY` — yerel gösterim için.
  final String currency;

  /// Yurt içi / yurt dışı (acentenin beyanı).
  final TourScope tourScope;

  /// Yurt dışı ilanda pasaport şartı var mı (mock)?
  final bool requiresPassport;

  /// Gerekli minimum pasaport statüsü (`requiresPassport` true ise anlamlı).
  final PassportType minimumPassportType;

  /// Vize şartı var mı (mock)?
  final bool requiresVisa;

  /// Acentenin metinle tanımladığı vize beklentisi (resmi doğrulama yok).
  final String? visaRequirementText;

  /// Optional local/mock visual asset path. No upload or remote fetch.
  final String? imageAssetPath;

  /// Optional deterministic visual theme key for premium fallback headers.
  final String? visualKey;

  /// Accepted assignments counted toward kota.
  final int acceptedAssignmentCount;

  /// Pending applications (shown for agency context).
  final int pendingApplicationCount;

  TourSummary copyWith({
    String? id,
    String? agencyId,
    String? title,
    String? description,
    String? departureCity,
    DepartureRegion? departureRegion,
    String? destinationCity,
    DestinationCluster? destinationCluster,
    String? routeSummary,
    TourStatus? status,
    DateTime? startsAt,
    DateTime? endsAt,
    bool? transportationIncluded,
    int? seatsOffered,
    int? creatorQuota,
    double? expectedDepositAmount,
    double? normalSalesPrice,
    String? currency,
    int? acceptedAssignmentCount,
    int? pendingApplicationCount,
    String? agencyLegalName,
    String? agencyOperatingCity,
    TourScope? tourScope,
    bool? requiresPassport,
    PassportType? minimumPassportType,
    bool? requiresVisa,
    String? visaRequirementText,
    String? imageAssetPath,
    String? visualKey,
  }) {
    return TourSummary(
      id: id ?? this.id,
      agencyId: agencyId ?? this.agencyId,
      title: title ?? this.title,
      description: description ?? this.description,
      departureCity: departureCity ?? this.departureCity,
      departureRegion: departureRegion ?? this.departureRegion,
      destinationCity: destinationCity ?? this.destinationCity,
      destinationCluster: destinationCluster ?? this.destinationCluster,
      routeSummary: routeSummary ?? this.routeSummary,
      status: status ?? this.status,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      transportationIncluded: transportationIncluded ?? this.transportationIncluded,
      seatsOffered: seatsOffered ?? this.seatsOffered,
      creatorQuota: creatorQuota ?? this.creatorQuota,
      expectedDepositAmount: expectedDepositAmount ?? this.expectedDepositAmount,
      normalSalesPrice: normalSalesPrice ?? this.normalSalesPrice,
      currency: currency ?? this.currency,
      acceptedAssignmentCount: acceptedAssignmentCount ?? this.acceptedAssignmentCount,
      pendingApplicationCount: pendingApplicationCount ?? this.pendingApplicationCount,
      agencyLegalName: agencyLegalName ?? this.agencyLegalName,
      agencyOperatingCity: agencyOperatingCity ?? this.agencyOperatingCity,
      tourScope: tourScope ?? this.tourScope,
      requiresPassport: requiresPassport ?? this.requiresPassport,
      minimumPassportType: minimumPassportType ?? this.minimumPassportType,
      requiresVisa: requiresVisa ?? this.requiresVisa,
      visaRequirementText: visaRequirementText ?? this.visaRequirementText,
      imageAssetPath: imageAssetPath ?? this.imageAssetPath,
      visualKey: visualKey ?? this.visualKey,
    );
  }

  /// True when ilan yeniden başvuruya tamamen kapalı (`APPLICATION_CLOSED` ve kota dolu ise).
  bool get isApplicationClosed => status == TourStatus.applicationClosed;

  /// Kota müsaitliği için kalan seçim hakları (mock sade gösterimi).
  int get remainingCreatorSlots =>
      (creatorQuota - acceptedAssignmentCount).clamp(0, creatorQuota);

  /// Üreticide “açık ilan”: yayımlandı ve kota veya süre iş kuralı mock’ta kota üzerinden.
  bool get isOpenForApplications =>
      status == TourStatus.published && remainingCreatorSlots > 0;
}
