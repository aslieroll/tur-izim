import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/api/api_client.dart';
import '../core/bootstrap/tur_izim_mock_bootstrap.dart';
import '../core/constants/app_constants.dart';
import '../core/di/tur_izim_dependencies.dart';
import '../features/auth/data/api_auth_repository.dart';
import '../features/auth/data/auth_token_storage.dart';
import '../features/auth/data/session_auth_repository.dart';
import 'router.dart';
import 'theme.dart';
import 'tur_izim_scope.dart';

/// Root widget: tema + GoRouter + JWT oturum geri yükleme.
class TurIzimApp extends StatefulWidget {
  const TurIzimApp({super.key});

  @override
  State<TurIzimApp> createState() => _TurIzimAppState();
}

class _TurIzimAppState extends State<TurIzimApp> {
  late final JwtAccessTokenHolder _tokenHolder = JwtAccessTokenHolder();
  late final TurIzimApiClient _apiClient = HttpTurIzimApiClient(
    accessToken: () => _tokenHolder.value,
  );
  late final ApiAuthRepository _apiAuth = ApiAuthRepository(_apiClient);
  late final SessionAuthRepository _session = SessionAuthRepository(
    tokenHolder: _tokenHolder,
    tokenStorage: AuthTokenStorage.instance,
    apiAuth: _apiAuth,
  );
  late final TurIzimMockBootstrap _mock =
      TurIzimMockBootstrap(apiClient: _apiClient);
  late final GoRouter _router = buildAppRouter(_session);
  late final Future<void> _bootstrapFuture = _session.restoreSessionOnLaunch();

  @override
  void dispose() {
    _apiClient.close();
    _session.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _bootstrapFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: TurIzimTheme.light,
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return TurIzimScope(
          session: _session,
          child: TurIzimDependencies(
            apiClient: _apiClient,
            tours: _mock.tours,
            applications: _mock.applications,
            assignments: _mock.assignments,
            deliveries: _mock.deliveries,
            publications: _mock.publications,
            violations: _mock.violations,
            creatorDashboard: _mock.creatorDashboard,
            agencyDashboard: _mock.agencyDashboard,
            adminDashboard: _mock.adminDashboard,
            aiMatch: _mock.aiMatch,
            child: MaterialApp.router(
              title: AppConstants.appName,
              debugShowCheckedModeBanner: false,
              theme: TurIzimTheme.light,
              routerConfig: _router,
            ),
          ),
        );
      },
    );
  }
}
