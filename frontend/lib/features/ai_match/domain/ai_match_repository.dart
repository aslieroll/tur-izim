/// Backend `RiskLevel` enum'u ile birebir eşleşen risk seviyesi.
enum AiMatchRiskLevel { low, medium, high }

/// `POST /api/ai/match-score` yanıtı.
///
/// Skor backend'de deterministik hesaplanır; `aiSummary` OpenRouter LLM
/// açıklamasıdır. AI erişilemezse backend `fallbackUsed: true` ile
/// deterministik özet döner — UI bunu normal şekilde gösterir.
class AiMatchResult {
  const AiMatchResult({
    required this.tourId,
    required this.creatorId,
    required this.fitnessScore,
    required this.riskLevel,
    required this.aiSummary,
    required this.fallbackUsed,
  });

  factory AiMatchResult.fromBackendJson(Map<String, dynamic> json) {
    return AiMatchResult(
      tourId: json['tourId']?.toString() ?? '',
      creatorId: json['creatorId']?.toString() ?? '',
      fitnessScore: (json['fitnessScore'] as num?)?.toInt() ?? 0,
      riskLevel: riskLevelFromBackend(json['riskLevel']?.toString()),
      aiSummary: json['aiSummary']?.toString() ?? '',
      fallbackUsed: json['fallbackUsed'] == true,
    );
  }

  final String tourId;
  final String creatorId;

  /// 0–100 deterministik uygunluk skoru.
  final int fitnessScore;
  final AiMatchRiskLevel riskLevel;
  final String aiSummary;

  /// `true` ise özet LLM'den değil deterministik kuraldan üretildi.
  final bool fallbackUsed;

  static AiMatchRiskLevel riskLevelFromBackend(String? raw) {
    return switch (raw) {
      'LOW' => AiMatchRiskLevel.low,
      'MEDIUM' => AiMatchRiskLevel.medium,
      'HIGH' => AiMatchRiskLevel.high,
      _ => AiMatchRiskLevel.high,
    };
  }
}

/// AI Match Assistant — karar desteğidir; otomatik seçim yapmaz.
abstract interface class AiMatchRepository {
  Future<AiMatchResult> evaluateMatch({
    required String tourId,
    required String creatorId,
  });
}
