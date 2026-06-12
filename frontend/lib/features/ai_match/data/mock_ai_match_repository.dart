import 'package:tur_izim/features/ai_match/domain/ai_match_repository.dart';

/// Backend kapalıyken kullanılan deterministik mock — rastgelelik içermez;
/// aynı tur + creator çifti her zaman aynı skoru üretir.
///
/// Skor backend formülünün kopyası değildir (mock tur kimlikleri UUID değildir);
/// yalnızca çevrimdışı demo için tutarlı bir karar destek görünümü sağlar.
final class MockAiMatchRepository implements AiMatchRepository {
  const MockAiMatchRepository();

  @override
  Future<AiMatchResult> evaluateMatch({
    required String tourId,
    required String creatorId,
  }) async {
    final score = _deterministicScore(tourId, creatorId);
    final risk = _riskFromScore(score);
    return AiMatchResult(
      tourId: tourId,
      creatorId: creatorId,
      fitnessScore: score,
      riskLevel: risk,
      aiSummary:
          'AI açıklaması şu anda kullanılamıyor. Deterministik skora göre '
          '($score/100) bu içerik üreticisi tur için ${_fitLabel(risk)}.',
      fallbackUsed: true,
    );
  }

  /// 55–95 aralığında, id kod birimlerinden türetilen sabit skor.
  static int _deterministicScore(String tourId, String creatorId) {
    var sum = 0;
    for (final c in tourId.codeUnits) {
      sum += c;
    }
    for (final c in creatorId.codeUnits) {
      sum += c;
    }
    return 55 + (sum % 41);
  }

  /// Backend `RiskLevel.fromScore` eşikleri ile aynı: 75 / 50.
  static AiMatchRiskLevel _riskFromScore(int score) {
    if (score >= 75) return AiMatchRiskLevel.low;
    if (score >= 50) return AiMatchRiskLevel.medium;
    return AiMatchRiskLevel.high;
  }

  static String _fitLabel(AiMatchRiskLevel risk) {
    return switch (risk) {
      AiMatchRiskLevel.low => 'güçlü bir aday',
      AiMatchRiskLevel.medium => 'kısmen uygun bir aday',
      AiMatchRiskLevel.high => 'düşük uyumlu bir aday',
    };
  }
}
