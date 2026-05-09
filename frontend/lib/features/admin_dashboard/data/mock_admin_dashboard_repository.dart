import 'package:tur_izim/core/mock/mock_tur_izim_store.dart';
import 'package:tur_izim/shared/models/pending_agency_review.dart';

import '../domain/admin_dashboard_repository.dart';

final class MockAdminDashboardRepository implements AdminDashboardRepository {
  MockAdminDashboardRepository(this._store);

  final MockTurIzimStore _store;

  @override
  Future<List<PendingAgencyReview>> listPendingApprovals() async {
    await Future<void>.delayed(const Duration(milliseconds: 35));
    return _store.pendingAgencyApprovals();
  }

  @override
  Future<void> setAgencyApproval({
    required String agencyId,
    required bool approve,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 45));
    await _store.adminSetAgencyApproval(agencyId: agencyId, approved: approve);
  }
}
