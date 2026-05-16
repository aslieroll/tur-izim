import 'package:tur_izim/core/mock/mock_tur_izim_store.dart';

import '../domain/agency_board_snapshot.dart';
import '../domain/agency_dashboard_repository.dart';

final class MockAgencyDashboardRepository implements AgencyDashboardRepository {
  MockAgencyDashboardRepository(this._store);

  final MockTurIzimStore _store;

  @override
  Future<AgencyBoardSnapshot> loadAgencyBoard(String agencyId) async {
    await Future<void>.delayed(const Duration(milliseconds: 35));
    final tours = _store.agencyTours(agencyId);
    final pending = _store.pendingApplicationsForAgency(agencyId);
    return AgencyBoardSnapshot(
      pendingApplicantCount: pending,
      tours: tours,
    );
  }
}
