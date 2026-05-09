import 'package:tur_izim/shared/models/tour_summary.dart';

import 'status_label_turkish.dart';

/// Presentation-only formatting for tour lists and detail (no business rules).
String formatTourCalendarDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

/// Liste ve kartlarda tur rotası; `route_summary` doluysa doğrudan o kullanılır.
/// Aksi halde çıkış şehri + varış kümesi/şehir etiketi.
String tourRouteOverviewLineTurkish(TourSummary tour) {
  final summary = tour.routeSummary?.trim();
  if (summary != null && summary.isNotEmpty) {
    return summary;
  }
  final destCity = tour.destinationCity?.trim();
  final destSegment = destCity != null && destCity.isNotEmpty
      ? destCity
      : destinationClusterLabelTurkish(tour.destinationCluster);
  return '${tour.departureCity.trim()} → $destSegment';
}

/// Acente ve tur detayı satırında “Faaliyet şehri” ile birlikte kullanılabilir.
String agencyDisplayLineWithCityTurkish(TourSummary tour) {
  final base = tour.agencyLegalName ?? 'Acente adı bu önizlemede yok';
  final c = tour.agencyOperatingCity?.trim();
  if (c != null && c.isNotEmpty) {
    return '$base · Faaliyet şehri: $c';
  }
  return base;
}
