import 'user_role.dart';

/// Stub session payload until OAuth / JWT-backed auth exists.
class SessionSnapshot {
  const SessionSnapshot({required this.userId, required this.role});

  final String userId;
  final UserRole role;
}
