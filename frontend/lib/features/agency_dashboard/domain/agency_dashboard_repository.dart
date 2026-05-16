import 'agency_board_snapshot.dart';

abstract class AgencyDashboardRepository {
  /// Turlar + toplam bekleyen başvuru (tek API turunda hesaplanır).
  Future<AgencyBoardSnapshot> loadAgencyBoard(String agencyId);
}
