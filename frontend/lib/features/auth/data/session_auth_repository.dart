import 'package:flutter/foundation.dart';

import '../../../core/constants/mock_actor_ids.dart';
import '../../../shared/models/session_snapshot.dart';
import '../../../shared/models/user_role.dart';
import '../domain/auth_repository.dart';

/// Role-based shell session suitable for Navigator refresh + redirects.
///
/// Persisted backend auth replaces this implementation later.
final class SessionAuthRepository extends ChangeNotifier
    implements AuthRepository {
  UserRole? _role;
  String? _userId;

  String? get userId => _userId;

  /// Mock kullanıcı profili — üreticide başvuran kimliği.
  String? get activeCreatorId =>
      _role == UserRole.creator ? MockActorIds.creatorAlice : null;

  /// Mock acente işletme kimliği.
  String? get activeAgencyId =>
      _role == UserRole.agency ? MockActorIds.approvedAgency : null;

  @override
  UserRole? get currentRole => _role;

  @override
  Future<SessionSnapshot?> readSnapshot() async {
    if (_role == null || _userId == null) {
      return null;
    }
    return SessionSnapshot(userId: _userId!, role: _role!);
  }

  @override
  Future<void> selectRole(UserRole role) async {
    _role = role;
    _userId = _mockUserIdFor(role);
    notifyListeners();
  }

  @override
  Future<void> clearSession() async {
    _role = null;
    _userId = null;
    notifyListeners();
  }

  static String _mockUserIdFor(UserRole role) {
    return switch (role) {
      UserRole.admin => 'mock-user-admin',
      UserRole.agency => 'mock-user-agency',
      UserRole.creator => 'mock-user-creator',
    };
  }
}
