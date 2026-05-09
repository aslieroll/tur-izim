import 'content_delivery_status.dart';

class ContentDelivery {
  const ContentDelivery({
    required this.id,
    required this.assignmentId,
    required this.draftContentUrl,
    required this.notes,
    required this.status,
    required this.revisionCount,
    required this.submittedAt,
    required this.approvedAt,
  });

  final String id;
  final String assignmentId;
  final String? draftContentUrl;
  final String? notes;
  final ContentDeliveryStatus status;
  final int revisionCount;
  final DateTime? submittedAt;
  final DateTime? approvedAt;
}
