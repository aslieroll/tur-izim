import 'package:tur_izim/core/api/api_client.dart';
import 'package:tur_izim/core/constants/mock_actor_ids.dart';
import 'package:tur_izim/features/auth/data/api_auth_repository.dart';
import 'package:tur_izim/features/auth/data/auth_token_storage.dart';
import 'package:tur_izim/features/auth/data/session_auth_repository.dart';

/// Widget / entegrasyon testleri için oturum.
SessionAuthRepository createTestSessionAuthRepository({
  bool withCreatorJwt = false,
  String creatorId = MockActorIds.creatorAlice,
}) {
  final holder = JwtAccessTokenHolder();
  final api = HttpTurIzimApiClient(accessToken: () => holder.value);
  final session = SessionAuthRepository(
    tokenHolder: holder,
    tokenStorage: AuthTokenStorage.instance,
    apiAuth: ApiAuthRepository(api),
  );
  if (withCreatorJwt) {
    session.simulateAuthenticatedCreator(creatorProfileId: creatorId);
  }
  return session;
}
