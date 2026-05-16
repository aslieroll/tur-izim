import 'package:tur_izim/shared/models/tour_summary.dart';

/// Acente operasyon özeti (dashboard tek yüklemesi).
class AgencyBoardSnapshot {
  const AgencyBoardSnapshot({
    required this.pendingApplicantCount,
    required this.tours,
  });

  final int pendingApplicantCount;
  final List<TourSummary> tours;
}
