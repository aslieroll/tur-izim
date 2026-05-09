import 'package:tur_izim/shared/models/publication_record.dart';

abstract class PublicationsRepository {
  Future<PublicationRecord?> fetchForAssignment(String assignmentId);

  Future<void> submitPublicationUrl({
    required String assignmentId,
    required String creatorId,
    required String publishedUrl,
  });

  Future<void> agencyVerifyPublication({
    required String assignmentId,
    required String actingAgencyId,
  });
}
