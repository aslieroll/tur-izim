import 'agency_status.dart';

/// Admin queue rows for agency onboarding (contract-sized for later mocks/API).
class PendingAgencyReview {
  const PendingAgencyReview({
    required this.id,
    required this.legalName,
    required this.status,
  });

  final String id;
  final String legalName;
  final AgencyStatus status;
}
