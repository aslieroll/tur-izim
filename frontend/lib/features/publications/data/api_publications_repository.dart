import 'package:tur_izim/core/api/api_client.dart';
import 'package:tur_izim/core/api/backend_dto_mappers.dart';
import 'package:tur_izim/features/publications/domain/publications_repository.dart';
import 'package:tur_izim/shared/models/publication_record.dart';

final class ApiPublicationsRepository implements PublicationsRepository {
  ApiPublicationsRepository(this._api);

  final TurIzimApiClient _api;

  @override
  Future<PublicationRecord?> fetchForAssignment(String assignmentId) async {
    final raw = await _api.getJsonOrNull('/api/assignments/$assignmentId/publication-proof');
    if (raw == null) return null;
    return publicationRecordFromBackendJson(raw, assignmentId);
  }

  @override
  Future<void> submitPublicationUrl({
    required String assignmentId,
    required String creatorId,
    required String publishedUrl,
  }) async {
    await _api.postJson('/api/assignments/$assignmentId/publication-proof', {
      'postUrl': publishedUrl,
      'cloudContentUrl': publishedUrl,
    });
  }

  @override
  Future<void> agencyVerifyPublication({
    required String assignmentId,
    required String actingAgencyId,
  }) async {
    // Admin / acente doğrulama ucu henüz yok.
  }
}
