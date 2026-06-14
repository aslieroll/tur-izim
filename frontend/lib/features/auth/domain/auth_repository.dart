import '../../../shared/models/session_snapshot.dart';
import '../../../shared/models/user_role.dart';
import 'auth_dtos.dart';

/// Session + kimlik doğrulama sözleşmesi.
abstract class AuthRepository {
  UserRole? get currentRole;

  /// Yerel olarak saklanmış ve doğrulanmış JWT oturumu.
  bool get isJwtAuthenticated;

  Future<SessionSnapshot?> readSnapshot();

  Future<void> selectRole(UserRole role);

  Future<void> clearSession();

  Future<void> signInWithPassword({
    required String email,
    required String password,
  });

  Future<void> registerCreatorAccount(RegisterCreatorRequest data);

  Future<void> registerAgencyAccount(RegisterAgencyRequest data);
}
