import 'package:tur_izim/core/api/api_client.dart';
import 'package:tur_izim/core/api/backend_dto_mappers.dart';
import 'package:tur_izim/core/errors/app_exception.dart';
import 'package:tur_izim/features/applications/domain/applications_repository.dart';
import 'package:tur_izim/shared/models/application_commitment.dart';
import 'package:tur_izim/shared/models/application_summary.dart';
import 'package:tur_izim/shared/models/rated_application.dart';

final class ApiApplicationsRepository implements ApplicationsRepository {
  ApiApplicationsRepository(this._api);

  final TurIzimApiClient _api;

  @override
  Future<ApplicationSummary?> findByTourAndCreator({
    required String tourId,
    required String creatorId,
  }) async {
    final list = await _api.getJsonList('/api/creators/$creatorId/applications');
    for (final raw in list) {
      final m = raw as Map<String, dynamic>;
      if (m['tourId']?.toString() == tourId) {
        return applicationSummaryFromBackendJson(m);
      }
    }
    return null;
  }

  @override
  Future<List<ApplicationSummary>> listByCreator(String creatorId) async {
    final list = await _api.getJsonList('/api/creators/$creatorId/applications');
    return list
        .map((e) => applicationSummaryFromBackendJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<RatedApplication>> listRatedApplicantsForTour({
    required String actingAgencyId,
    required String tourId,
  }) async {
    final list = await _api.getJsonList('/api/agency/tours/$tourId/applications');
    final out = <RatedApplication>[];
    for (final raw in list) {
      final m = raw as Map<String, dynamic>;
      final creatorId = m['creatorId']?.toString();
      if (creatorId == null) continue;
      final cj = await _api.getJson('/api/creators/$creatorId');
      final creator = creatorProfileFromBackendJson(cj);
      out.add(ratedApplicationFromBackendRow(m, creator));
    }
    return out;
  }

  @override
  Future<void> submitApplication({
    required String creatorId,
    required String tourId,
    required ApplicationCommitment commitment,
    String? message,
  }) async {
    if (!commitment.isComplete) {
      throw AppException('Taahhüt kutularının tamamı işaretlenmelidir.');
    }
    await _api.postJson('/api/tours/$tourId/applications', {
      'creatorId': creatorId,
      'applicationNote': message,
      'acceptedThirtyDayPublicationCommitment': true,
      'acceptedAgencyContentUsageRights': true,
      'acceptedEarlyRemovalFullFeeRule': true,
    });
  }

  @override
  Future<void> withdrawApplication({
    required String applicationId,
    required String creatorId,
  }) async {
    throw AppException(
      'Bu MVP sürümünde başvuru geri çekme yalnızca çevrimdışı demoda desteklenir. '
      'API ile geri çekme henüz yok.',
    );
  }
}
