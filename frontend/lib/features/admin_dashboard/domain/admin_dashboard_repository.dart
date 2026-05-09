import 'package:tur_izim/shared/models/pending_agency_review.dart';

abstract class AdminDashboardRepository {
  Future<List<PendingAgencyReview>> listPendingApprovals();

  Future<void> setAgencyApproval({
    required String agencyId,
    required bool approve,
  });
}
