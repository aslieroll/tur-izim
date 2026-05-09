import 'package:tur_izim/shared/models/content_delivery.dart';

abstract class DeliveriesRepository {
  Future<ContentDelivery?> fetchLatestDelivery(String assignmentId);

  Future<void> submitDraftUrl({
    required String assignmentId,
    required String creatorId,
    required String url,
    String? notes,
  });

  Future<void> approveDraft({
    required String assignmentId,
    required String actingAgencyId,
  });

  Future<void> requestTechnicalRevision({
    required String assignmentId,
    required String actingAgencyId,
    required String checklistNotes,
  });
}
