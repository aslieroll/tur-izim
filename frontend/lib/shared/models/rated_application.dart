import 'application_summary.dart';
import 'creator_profile.dart';
import 'suitability_scores.dart';

/// Acente başvuran listesi satırı (sıra depo tarafından verilir).
class RatedApplication {
  const RatedApplication({
    required this.summary,
    required this.creator,
    required this.scores,
  });

  final ApplicationSummary summary;
  final CreatorProfile creator;
  final SuitabilityScores scores;
}
