import 'package:tur_izim/shared/models/tour_summary.dart';

abstract class AgencyDashboardRepository {
  Future<List<TourSummary>> featuredTours(String agencyId);

  Future<int> countAwaitingApplicants(String agencyId);
}
