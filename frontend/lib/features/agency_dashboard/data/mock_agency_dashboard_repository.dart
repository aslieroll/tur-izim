import 'package:tur_izim/core/mock/mock_tur_izim_store.dart';
import 'package:tur_izim/shared/models/tour_summary.dart';

import '../domain/agency_dashboard_repository.dart';

final class MockAgencyDashboardRepository implements AgencyDashboardRepository {
  MockAgencyDashboardRepository(this._store);

  final MockTurIzimStore _store;

  @override
  Future<int> countAwaitingApplicants(String agencyId) async {
    await Future<void>.delayed(const Duration(milliseconds: 30));
    return _store.pendingApplicationsForAgency(agencyId);
  }

  @override
  Future<List<TourSummary>> featuredTours(String agencyId) async {
    await Future<void>.delayed(const Duration(milliseconds: 35));
    return _store.agencyTours(agencyId);
  }
}
