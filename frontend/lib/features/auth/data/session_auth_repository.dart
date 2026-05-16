import 'package:flutter/foundation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/constants/mock_actor_ids.dart';
import '../../../core/demo/mvp_demo_identity.dart';
import '../../../shared/models/session_snapshot.dart';
import '../../../shared/models/user_role.dart';
import '../domain/auth_repository.dart';

/// Role-based shell session suitable for Navigator refresh + redirects.
///
/// **MVP:** Kimlik yok; creator/agency için örnek UUID’ler backend seed’den okunur.
final class SessionAuthRepository extends ChangeNotifier implements AuthRepository {
  UserRole? _role;
  String? _userId;

  /// `GET /api/tours` ve `/api/creators` başarılıysa `true`.
  bool demoBackendIdentityPrimed = false;

  String? _demoCreatorIdFromApi;
  String? _demoAgencyIdFromApi;

  String? get userId => _userId;

  /// Önce `DEMO_CREATOR_ID` dart-define, sonra API seed, son mock sabit.
  String? get activeCreatorId =>
      _role == UserRole.creator ? _resolvedDemoCreatorId() : null;

  /// Önce `DEMO_AGENCY_ID` dart-define, sonra API seed ([primeDemoIdentityFromApi]), son mock sabit.
  String? get activeAgencyId =>
      _role == UserRole.agency ? _resolvedDemoAgencyId() : null;

  String? _resolvedDemoCreatorId() {
    if (MvpDemoIdentity.creatorIdOverride.isNotEmpty) {
      return MvpDemoIdentity.creatorIdOverride;
    }
    return _demoCreatorIdFromApi ?? MockActorIds.creatorAlice;
  }

  String? _resolvedDemoAgencyId() {
    if (MvpDemoIdentity.agencyIdOverride.isNotEmpty) {
      return MvpDemoIdentity.agencyIdOverride;
    }
    return _demoAgencyIdFromApi ?? MockActorIds.approvedAgency;
  }

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

  /// Yerel Spring Boot çalışıyorsa ilk turun `agencyId` ve ilk creator `id` alınır.
  Future<void> primeDemoIdentityFromApi(TurIzimApiClient client) async {
    _demoCreatorIdFromApi = null;
    _demoAgencyIdFromApi = null;
    demoBackendIdentityPrimed = false;
    try {
      final tours = await client.getJsonList('/api/tours');
      if (tours.isEmpty) {
        notifyListeners();
        return;
      }
      final f = tours.first as Map<String, dynamic>;
      _demoAgencyIdFromApi = f['agencyId']?.toString();

      final creators = await client.getJsonList('/api/creators');
      if (creators.isEmpty) {
        notifyListeners();
        return;
      }
      final c = creators.first as Map<String, dynamic>;
      _demoCreatorIdFromApi = c['id']?.toString();
      demoBackendIdentityPrimed =
          _demoAgencyIdFromApi != null && _demoCreatorIdFromApi != null;
    } on Object {
      demoBackendIdentityPrimed = false;
    }
    notifyListeners();
  }

  @override
  Future<void> clearSession() async {
    _role = null;
    _userId = null;
    _demoCreatorIdFromApi = null;
    _demoAgencyIdFromApi = null;
    demoBackendIdentityPrimed = false;
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
