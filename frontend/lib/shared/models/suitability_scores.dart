/// Sunucunun hesapladığı uygunluk değerleri (UI yalın gösterir).
class SuitabilityScores {
  const SuitabilityScores({
    required this.aue,
    required this.technicalFit,
    required this.publicationFit,
    required this.matchedRequirementCount,
    required this.totalRequirementCount,
    required this.missingRequirementsText,
  });

  /// applications.suitability_score
  final double aue;

  /// Teknik uyum yüzdesi.
  final double technicalFit;

  /// Yayın platform uyumu yüzdesi.
  final double publicationFit;

  final int matchedRequirementCount;
  final int totalRequirementCount;
  final String missingRequirementsText;
}
