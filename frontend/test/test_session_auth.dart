import 'package:tur_izim/core/api/api_client.dart';
import 'package:tur_izim/features/auth/data/api_auth_repository.dart';
import 'package:tur_izim/features/auth/data/auth_token_storage.dart';
import 'package:tur_izim/features/auth/data/session_auth_repository.dart';

/// Widget / entegrasyon testleri için oturum (JWT’siz; yalnızca rol seçimi).
SessionAuthRepository createTestSessionAuthRepository() {
  final holder = JwtAccessTokenHolder();
  final api = HttpTurIzimApiClient(accessToken: () => holder.value);
  return SessionAuthRepository(
    tokenHolder: holder,
    tokenStorage: AuthTokenStorage.instance,
    apiAuth: ApiAuthRepository(api),
  );
}
