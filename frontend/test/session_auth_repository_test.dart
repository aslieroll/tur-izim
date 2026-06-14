import 'package:flutter_test/flutter_test.dart';
import 'package:tur_izim/core/api/api_client.dart';
import 'package:tur_izim/core/api/api_exception.dart';
import 'package:tur_izim/core/constants/mock_actor_ids.dart';
import 'package:tur_izim/features/auth/data/api_auth_repository.dart';
import 'package:tur_izim/features/auth/data/auth_token_storage.dart';
import 'package:tur_izim/features/auth/data/session_auth_repository.dart';
import 'package:tur_izim/shared/models/user_role.dart';

void main() {
  SessionAuthRepository buildSession() {
    final holder = JwtAccessTokenHolder();
    final api = HttpTurIzimApiClient(accessToken: () => holder.value);
    return SessionAuthRepository(
      tokenHolder: holder,
      tokenStorage: AuthTokenStorage.instance,
      apiAuth: ApiAuthRepository(api),
    );
  }

  test('activeCreatorId is null without JWT even when creator role selected', () async {
    final session = buildSession();
    await session.selectRole(UserRole.creator);
    expect(session.activeCreatorId, isNull);
    expect(session.canAccessProtectedCreatorEndpoints, isFalse);
  });

  test('activeCreatorId uses JWT profile id not hardcoded demo id', () {
    final session = buildSession();
    const jwtCreatorId = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890';
    session.simulateAuthenticatedCreator(creatorProfileId: jwtCreatorId);
    expect(session.activeCreatorId, jwtCreatorId);
    expect(session.activeCreatorId, isNot(MockActorIds.creatorAlice));
    expect(session.canAccessProtectedCreatorEndpoints, isTrue);
  });

  test('ApiException.isUnauthorized is true for 401', () {
    final ex = ApiException(userMessage: 'Unauthorized', statusCode: 401);
    expect(ex.isUnauthorized, isTrue);
    expect(ex.isAuthRequired, isTrue);
  });
}
