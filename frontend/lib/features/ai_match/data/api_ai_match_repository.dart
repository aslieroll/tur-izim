import 'package:tur_izim/core/api/api_client.dart';
import 'package:tur_izim/features/ai_match/domain/ai_match_repository.dart';

/// `POST /api/ai/match-score` çağrısı (gövdede UUID string'leri).
final class ApiAiMatchRepository implements AiMatchRepository {
  ApiAiMatchRepository(this._api);

  final TurIzimApiClient _api;

  @override
  Future<AiMatchResult> evaluateMatch({
    required String tourId,
    required String creatorId,
  }) async {
    final json = await _api.postJson('/api/ai/match-score', {
      'tourId': tourId,
      'creatorId': creatorId,
    });
    return AiMatchResult.fromBackendJson(json);
  }
}
