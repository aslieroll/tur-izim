import 'package:tur_izim/core/api/api_client.dart';
import 'package:tur_izim/core/api/api_exception.dart';
import 'package:tur_izim/core/api/backend_dto_mappers.dart';
import 'package:tur_izim/features/tours/domain/tour_repository.dart';
import 'package:tur_izim/shared/models/creator_profile.dart';
import 'package:tur_izim/shared/models/tour_detail.dart';
import 'package:tur_izim/shared/models/tour_summary.dart';
import 'package:tur_izim/shared/models/tour_scope.dart';
import 'package:tur_izim/shared/models/passport_type.dart';
import 'package:tur_izim/shared/models/visa_eligibility_status.dart';

/// Doğrudan Spring Boot tur uçları (mock fallback yok).
final class ApiTourRepository implements TourRepository {
  ApiTourRepository(this._api);

  final TurIzimApiClient _api;

  @override
  Future<List<TourSummary>> fetchAgencyTours(String agencyId) async {
    final list = await _api.getJsonList('/api/agency/$agencyId/tours');
    return list.map((e) => tourSummaryFromBackendJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<TourDetail?> fetchTourDetail(String id) async {
    try {
      final j = await _api.getJson('/api/tours/$id');
      return tourDetailFromBackendTourJson(j);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<List<TourSummary>> fetchPublishedTours() async {
    final list = await _api.getJsonList('/api/tours');
    return list.map((e) => tourSummaryFromBackendJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<TourSummary>> fetchPublishedToursForCreator(String creatorId) async {
    final tours = await fetchPublishedTours();
    final creator = await _tryCreator(creatorId);
    if (creator == null) return tours;
    return tours
        .where((t) => _eligibleForTour(creator, t))
        .toList();
  }

  Future<CreatorProfile?> _tryCreator(String id) async {
    try {
      final j = await _api.getJson('/api/creators/$id');
      return creatorProfileFromBackendJson(j);
    } on Object {
      return null;
    }
  }

  bool _eligibleForTour(CreatorProfile c, TourSummary t) {
    if (t.tourScope == TourScope.domestic) return true;
    if (t.requiresPassport) {
      if (!c.hasValidPassport || c.passportType == PassportType.none) {
        return false;
      }
      if (c.passportType.strengthRank < t.minimumPassportType.strengthRank) {
        return false;
      }
    }
    if (t.requiresVisa) {
      return c.visaEligibility == VisaEligibilityStatus.hasRequiredVisa;
    }
    return true;
  }

  @override
  Future<bool> isCreatorEligibleForTour({
    required String creatorId,
    required String tourId,
  }) async {
    final tour = await fetchTourDetail(tourId);
    final creator = await _tryCreator(creatorId);
    if (tour == null || creator == null) return false;
    return _eligibleForTour(creator, tour);
  }

  @override
  Future<bool> hasCreatorApplied({
    required String tourId,
    required String creatorId,
  }) async {
    final list = await _api.getJsonList('/api/creators/$creatorId/applications');
    for (final raw in list) {
      final m = raw as Map<String, dynamic>;
      if (m['tourId']?.toString() == tourId) return true;
    }
    return false;
  }
}
