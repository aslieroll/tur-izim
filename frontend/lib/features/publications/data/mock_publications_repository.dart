import 'package:tur_izim/core/mock/mock_tur_izim_store.dart';
import 'package:tur_izim/shared/models/publication_record.dart';

import '../domain/publications_repository.dart';

final class MockPublicationsRepository implements PublicationsRepository {
  MockPublicationsRepository(this._store);

  final MockTurIzimStore _store;

  @override
  Future<void> agencyVerifyPublication({
    required String assignmentId,
    required String actingAgencyId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 55));
    await _store.agencyVerifyPublication(
      assignmentId: assignmentId,
      actingAgencyId: actingAgencyId,
    );
  }

  @override
  Future<PublicationRecord?> fetchForAssignment(String assignmentId) async {
    await Future<void>.delayed(const Duration(milliseconds: 25));
    return _store.publicationSnapshot(assignmentId);
  }

  @override
  Future<void> submitPublicationUrl({
    required String assignmentId,
    required String creatorId,
    required String publishedUrl,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 55));
    await _store.submitPublicationUrl(
      assignmentId: assignmentId,
      creatorId: creatorId,
      url: publishedUrl,
    );
  }
}
