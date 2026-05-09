import 'assignment_status.dart';
import 'mock_deposit_status.dart';

/// Rows shaped like future `assignments` list API responses.
class AssignmentSummary {
  const AssignmentSummary({
    required this.id,
    required this.tourId,
    required this.applicationId,
    required this.status,
    this.tourTitle,
    this.agencyLegalName,
    this.depositStatus,
  });

  final String id;
  final String tourId;
  final String applicationId;
  final AssignmentStatus status;

  /// Liste görünümü için mock/API birleşik alanlar.
  final String? tourTitle;
  final String? agencyLegalName;

  /// Salt okunur özet (acenteye liste için).
  final MockDepositStatus? depositStatus;
}
