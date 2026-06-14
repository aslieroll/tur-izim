import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tur_izim/features/auth/data/auth_token_storage.dart';

void main() {
  test('AuthTokenStorage persists token', () async {
    SharedPreferences.setMockInitialValues({});
    final s = AuthTokenStorage.instance;
    expect(await s.loadToken(), isNull);
    await s.saveToken('tok');
    expect(await s.loadToken(), 'tok');
    await s.clearStoredToken();
    expect(await s.loadToken(), isNull);
  });
}
