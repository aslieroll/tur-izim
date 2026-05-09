import 'publication_status.dart';
import 'social_platform.dart';

class PublicationRecord {
  const PublicationRecord({
    required this.id,
    required this.assignmentId,
    required this.platform,
    required this.publishedUrl,
    required this.status,
    required this.submittedAt,
    required this.verifiedAt,
    required this.monitoringStartDate,
    required this.monitoringEndDate,
  });

  final String id;
  final String assignmentId;
  final SocialPlatform platform;

  /// Yayındaki gönderi bağlantısı.
  final String? publishedUrl;
  final PublicationStatus status;

  final DateTime? submittedAt;
  final DateTime? verifiedAt;

  final DateTime? monitoringStartDate;
  final DateTime? monitoringEndDate;
}
