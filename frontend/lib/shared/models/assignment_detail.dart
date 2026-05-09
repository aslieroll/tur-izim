import 'assignment_summary.dart';
import 'content_delivery.dart';
import 'mock_deposit.dart';
import 'publication_record.dart';
import 'tour_summary.dart';

class AssignmentDetail {
  const AssignmentDetail({
    required this.summary,
    required this.tour,
    this.deposit,
    required this.delivery,
    required this.publication,
    required this.creatorDepositAcknowledgedAt,
    this.applicationMessage,
  });

  final AssignmentSummary summary;
  final TourSummary tour;
  final MockDeposit? deposit;
  final ContentDelivery? delivery;
  final PublicationRecord? publication;

  final DateTime? creatorDepositAcknowledgedAt;

  /// Kabul edilmiş başvurunun üretici notu (varsa).
  final String? applicationMessage;
}
