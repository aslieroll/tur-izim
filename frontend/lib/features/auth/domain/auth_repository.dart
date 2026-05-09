import '../../../shared/models/session_snapshot.dart';
import '../../../shared/models/user_role.dart';

/// Session contract; production auth will satisfy the same shape via API tokens.
abstract class AuthRepository {
  /// Current mocked role after [selectRole], or `null` when signed out.
  UserRole? get currentRole;

  Future<SessionSnapshot?> readSnapshot();

  Future<void> selectRole(UserRole role);

  Future<void> clearSession();
}
