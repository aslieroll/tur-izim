import 'package:flutter/foundation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/constants/mock_actor_ids.dart';
import '../../../core/demo/mvp_demo_identity.dart';
import '../../../shared/models/session_snapshot.dart';
import '../../../shared/models/user_role.dart';
import '../domain/auth_dtos.dart';
import '../domain/auth_repository.dart';
import 'api_auth_repository.dart';
import 'auth_token_storage.dart';

/// Shell oturumu + JWT / demo fallback.
final class SessionAuthRepository extends ChangeNotifier
    implements AuthRepository {
  SessionAuthRepository({
    required JwtAccessTokenHolder tokenHolder,
    required AuthTokenStorage tokenStorage,
    required ApiAuthRepository apiAuth,
  })  : _tokenHolder = tokenHolder,
        _tokenStorage = tokenStorage,
        _apiAuth = apiAuth;

  final JwtAccessTokenHolder _tokenHolder;
  final AuthTokenStorage _tokenStorage;
  final ApiAuthRepository _apiAuth;

  UserRole? _role;
  String? _userId;

  /// `true` [restoreSessionOnLaunch] tamamlandıktan sonra.
  bool bootstrapComplete = false;

  /// JWT ile oturum açıldıysa backend’ten gelen profil kimlikleri.
  String? _jwtCreatorProfileId;
  String? _jwtAgencyId;
  bool _isJwtSession = false;

  /// `GET /api/tours` ve `/api/creators` başarılıysa `true` (demo kimlik için).
  bool demoBackendIdentityPrimed = false;

  String? _demoCreatorIdFromApi;
  String? _demoAgencyIdFromApi;

  String? get userId => _userId;

  @override
  bool get isJwtAuthenticated =>
      _isJwtSession &&
      (_tokenHolder.value?.isNotEmpty ?? false);

  @override
  UserRole? get currentRole => _role;

  /// Önce dart-define, sonra JWT profili, sonra API seed, son mock sabit.
  String? get activeCreatorId =>
      _role == UserRole.creator ? _resolvedCreatorId() : null;

  /// Önce dart-define, sonra JWT acente id, sonra API seed, son mock sabit.
  String? get activeAgencyId =>
      _role == UserRole.agency ? _resolvedAgencyId() : null;

  String? _resolvedCreatorId() {
    if (MvpDemoIdentity.creatorIdOverride.isNotEmpty) {
      return MvpDemoIdentity.creatorIdOverride;
    }
    if (isJwtAuthenticated && _jwtCreatorProfileId != null) {
      return _jwtCreatorProfileId;
    }
    return _demoCreatorIdFromApi ?? MockActorIds.creatorAlice;
  }

  String? _resolvedAgencyId() {
    if (MvpDemoIdentity.agencyIdOverride.isNotEmpty) {
      return MvpDemoIdentity.agencyIdOverride;
    }
    if (isJwtAuthenticated && _jwtAgencyId != null) {
      return _jwtAgencyId;
    }
    return _demoAgencyIdFromApi ?? MockActorIds.approvedAgency;
  }

  /// Uygulama açılışında: saklı JWT → `/api/auth/me` → oturum veya temiz çıkış.
  Future<void> restoreSessionOnLaunch() async {
    try {
      final stored = await _tokenStorage.loadToken();
      if (stored == null || stored.isEmpty) {
        _tokenHolder.value = null;
        _clearJwtProfileFields();
        bootstrapComplete = true;
        notifyListeners();
        return;
      }
      _tokenHolder.value = stored;
      final me = await _apiAuth.fetchCurrentUser();
      _applyCurrentUser(me);
      _isJwtSession = true;
    } on Object {
      await _clearJwtArtifacts();
      _role = null;
      _userId = null;
    } finally {
      bootstrapComplete = true;
      notifyListeners();
    }
  }

  void _applyCurrentUser(CurrentUserResponse me) {
    _role = me.role;
    _userId = me.userId;
    _jwtCreatorProfileId = me.creatorProfileId;
    _jwtAgencyId = me.agencyId;
    _isJwtSession = true;
  }

  void _applyAuthResponse(AuthResponse r) {
    _tokenHolder.value = r.token;
    _role = r.role;
    _userId = r.userId;
    _jwtCreatorProfileId = r.creatorProfileId;
    _jwtAgencyId = r.agencyId;
    _isJwtSession = true;
  }

  Future<void> _persistToken(String token) async {
    await _tokenStorage.saveToken(token);
  }

  Future<void> _clearJwtArtifacts() async {
    _tokenHolder.value = null;
    await _tokenStorage.clearStoredToken();
    _clearJwtProfileFields();
  }

  void _clearJwtProfileFields() {
    _jwtCreatorProfileId = null;
    _jwtAgencyId = null;
    _isJwtSession = false;
  }

  /// Demo girişi öncesi yalnızca JWT kaydını temizler (rol atanmadan önce).
  Future<void> _clearJwtForDemoSwitch() async {
    await _clearJwtArtifacts();
  }

  @override
  Future<SessionSnapshot?> readSnapshot() async {
    if (_role == null || _userId == null) {
      return null;
    }
    return SessionSnapshot(userId: _userId!, role: _role!);
  }

  @override
  Future<void> selectRole(UserRole role) async {
    await _clearJwtForDemoSwitch();
    _role = role;
    _userId = _mockUserIdFor(role);
    notifyListeners();
  }

  /// Yerel Spring Boot çalışıyorsa ilk turun `agencyId` ve ilk creator `id` alınır (demo).
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
    await _clearJwtArtifacts();
    _demoCreatorIdFromApi = null;
    _demoAgencyIdFromApi = null;
    demoBackendIdentityPrimed = false;
    notifyListeners();
  }

  @override
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final res = await _apiAuth.login(
      LoginRequest(email: email.trim(), password: password),
    );
    if (res.token.isEmpty) {
      throw StateError('Sunucu token döndürmedi.');
    }
    _applyAuthResponse(res);
    await _persistToken(res.token);
    notifyListeners();
  }

  @override
  Future<void> registerCreatorAccount(RegisterCreatorRequest data) async {
    final res = await _apiAuth.registerCreator(data);
    if (res.token.isEmpty) {
      throw StateError('Sunucu token döndürmedi.');
    }
    _applyAuthResponse(res);
    await _persistToken(res.token);
    notifyListeners();
  }

  @override
  Future<void> registerAgencyAccount(RegisterAgencyRequest data) async {
    final res = await _apiAuth.registerAgency(data);
    if (res.token.isEmpty) {
      throw StateError('Sunucu token döndürmedi.');
    }
    _applyAuthResponse(res);
    await _persistToken(res.token);
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
