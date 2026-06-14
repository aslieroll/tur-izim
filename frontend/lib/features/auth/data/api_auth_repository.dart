import '../../../core/api/api_client.dart';
import '../domain/auth_dtos.dart';

/// Backend `/api/auth/*` uçları (JWT döner veya `/me` özet).
final class ApiAuthRepository {
  ApiAuthRepository(this._client);

  final TurIzimApiClient _client;

  Future<AuthResponse> login(LoginRequest body) async {
    final m = await _client.postJson('/api/auth/login', body.toJson());
    return AuthResponse.fromJson(m);
  }

  Future<AuthResponse> registerCreator(RegisterCreatorRequest body) async {
    final m =
        await _client.postJson('/api/auth/register/creator', body.toJson());
    return AuthResponse.fromJson(m);
  }

  Future<AuthResponse> registerAgency(RegisterAgencyRequest body) async {
    final m =
        await _client.postJson('/api/auth/register/agency', body.toJson());
    return AuthResponse.fromJson(m);
  }

  Future<CurrentUserResponse> fetchCurrentUser() async {
    final m = await _client.getJson('/api/auth/me');
    return CurrentUserResponse.fromJson(m);
  }
}
