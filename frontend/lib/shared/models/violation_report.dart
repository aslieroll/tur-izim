import 'violation_report_status.dart';

class ViolationReport {
  const ViolationReport({
    required this.id,
    required this.assignmentId,
    required this.publicationId,
    required this.reportedByAgencyId,
    required this.reason,
    required this.evidenceUrl,
    required this.status,
    required this.createdAt,
    required this.resolvedAt,
  });

  final String id;
  final String assignmentId;
  final String publicationId;
  final String reportedByAgencyId;
  final String reason;
  final String? evidenceUrl;
  final ViolationReportStatus status;
  final DateTime createdAt;
  final DateTime? resolvedAt;
}
