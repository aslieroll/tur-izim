import 'package:flutter_test/flutter_test.dart';

import 'package:tur_izim/features/ai_match/data/mock_ai_match_repository.dart';
import 'package:tur_izim/features/ai_match/domain/ai_match_repository.dart';

void main() {
  group('AiMatchResult.fromBackendJson', () {
    test('backend yanıtını doğru parse eder', () {
      final result = AiMatchResult.fromBackendJson({
        'tourId': 'aaaa-bbbb',
        'creatorId': 'cccc-dddd',
        'fitnessScore': 87,
        'riskLevel': 'LOW',
        'aiSummary': 'Uygun aday.',
        'fallbackUsed': false,
      });

      expect(result.tourId, 'aaaa-bbbb');
      expect(result.creatorId, 'cccc-dddd');
      expect(result.fitnessScore, 87);
      expect(result.riskLevel, AiMatchRiskLevel.low);
      expect(result.aiSummary, 'Uygun aday.');
      expect(result.fallbackUsed, isFalse);
    });

    test('fallbackUsed true yanıtı parse eder', () {
      final result = AiMatchResult.fromBackendJson({
        'tourId': 't',
        'creatorId': 'c',
        'fitnessScore': 40,
        'riskLevel': 'HIGH',
        'aiSummary': 'AI açıklaması şu anda kullanılamıyor.',
        'fallbackUsed': true,
      });

      expect(result.riskLevel, AiMatchRiskLevel.high);
      expect(result.fallbackUsed, isTrue);
    });

    test('bilinmeyen risk seviyesi güvenli şekilde HIGH olur', () {
      expect(
        AiMatchResult.riskLevelFromBackend('UNEXPECTED'),
        AiMatchRiskLevel.high,
      );
      expect(AiMatchResult.riskLevelFromBackend(null), AiMatchRiskLevel.high);
    });
  });

  group('MockAiMatchRepository', () {
    const repo = MockAiMatchRepository();

    test('aynı girdi her zaman aynı skoru üretir (deterministik)', () async {
      final a = await repo.evaluateMatch(tourId: 'tour-1', creatorId: 'creator-1');
      final b = await repo.evaluateMatch(tourId: 'tour-1', creatorId: 'creator-1');

      expect(a.fitnessScore, b.fitnessScore);
      expect(a.riskLevel, b.riskLevel);
      expect(a.aiSummary, b.aiSummary);
    });

    test('skor 0-100 aralığında ve fallback işaretli', () async {
      final r = await repo.evaluateMatch(
        tourId: 'tour-kapadokya-1',
        creatorId: 'creator-alice',
      );

      expect(r.fitnessScore, inInclusiveRange(0, 100));
      expect(r.fallbackUsed, isTrue);
      expect(r.aiSummary, isNotEmpty);
    });
  });
}
