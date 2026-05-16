import 'package:tur_izim/core/api/api_client.dart';
import 'package:tur_izim/core/api/backend_dto_mappers.dart';

import '../domain/agency_board_snapshot.dart';
import '../domain/agency_dashboard_repository.dart';
import 'package:tur_izim/shared/models/tour_summary.dart';

final class ApiAgencyDashboardRepository implements AgencyDashboardRepository {
  ApiAgencyDashboardRepository(this._api);

  final TurIzimApiClient _api;

  @override
  Future<AgencyBoardSnapshot> loadAgencyBoard(String agencyId) async {
    final list = await _api.getJsonList('/api/agency/$agencyId/tours');
    final base = list
        .map((e) => tourSummaryFromBackendJson(e as Map<String, dynamic>))
        .toList();

    var totalPending = 0;
    final enriched = <TourSummary>[];

    for (final tour in base) {
      final stats = await _statsForTour(tour.id);
      totalPending += stats.pending;
      enriched.add(
        tour.copyWith(
          pendingApplicationCount: stats.pending,
          acceptedAssignmentCount: stats.selectedPipeline,
        ),
      );
    }

    return AgencyBoardSnapshot(
      pendingApplicantCount: totalPending,
      tours: enriched,
    );
  }

  Future<({int pending, int selectedPipeline})> _statsForTour(String tourId) async {
    final apps = await _api.getJsonList('/api/agency/tours/$tourId/applications');
    var pending = 0;
    var selected = 0;
    for (final raw in apps) {
      final m = raw as Map<String, dynamic>;
      final st = m['status']?.toString();
      if (st == 'PENDING_REVIEW') pending++;
      if (st == 'SELECTED') selected++;
    }
    return (pending: pending, selectedPipeline: selected);
  }
}
