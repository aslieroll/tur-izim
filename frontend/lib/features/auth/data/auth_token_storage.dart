import 'package:shared_preferences/shared_preferences.dart';

/// In-memory bearer token synchronized with [AuthTokenStorage] for HTTP headers.
final class JwtAccessTokenHolder {
  String? value;
}

/// Persists JWT for session restore (web + mobile; MVP local demo).
final class AuthTokenStorage {
  AuthTokenStorage._();

  static const storageKey = 'tur_izim_jwt';

  static final AuthTokenStorage instance = AuthTokenStorage._();

  Future<String?> loadToken() async {
    final p = await SharedPreferences.getInstance();
    final v = p.getString(storageKey);
    if (v == null || v.isEmpty) return null;
    return v;
  }

  Future<void> saveToken(String token) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(storageKey, token);
  }

  Future<void> clearStoredToken() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(storageKey);
  }
}
