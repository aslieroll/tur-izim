import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/api/api_client.dart';
import '../core/bootstrap/tur_izim_mock_bootstrap.dart';
import '../core/constants/app_constants.dart';
import '../core/di/tur_izim_dependencies.dart';
import '../features/auth/data/session_auth_repository.dart';
import 'router.dart';
import 'theme.dart';
import 'tur_izim_scope.dart';

/// Root widget wiring theme plus GoRouter guarded by mocked session roles.
class TurIzimApp extends StatefulWidget {
  const TurIzimApp({super.key});

  @override
  State<TurIzimApp> createState() => _TurIzimAppState();
}

class _TurIzimAppState extends State<TurIzimApp> {
  late final SessionAuthRepository _session = SessionAuthRepository();
  late final TurIzimApiClient _apiClient = HttpTurIzimApiClient();
  late final TurIzimMockBootstrap _mock = TurIzimMockBootstrap(apiClient: _apiClient);
  late final GoRouter _router = buildAppRouter(_session);

  @override
  void dispose() {
    _apiClient.close();
    _session.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        child: MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: TurIzimTheme.light,
          routerConfig: _router,
        ),
      ),
    );
  }
}
