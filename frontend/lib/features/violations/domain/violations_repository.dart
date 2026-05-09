import 'package:tur_izim/shared/models/violation_report.dart';

abstract class ViolationsRepository {
  Future<void> createViolationReport({
    required String assignmentId,
    required String publicationId,
    required String reporterAgencyId,
    required String reason,
    String? evidenceUrl,
  });

  Future<List<ViolationReport>> listForAdmin();

  Future<void> resolveByAdmin({
    required String violationId,
    required String resolutionNote,
    required bool confirmViolation,
  });
}
