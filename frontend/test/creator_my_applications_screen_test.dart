import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tur_izim/app/tur_izim_scope.dart';
import 'package:tur_izim/core/api/api_client.dart';
import 'package:tur_izim/core/bootstrap/tur_izim_mock_bootstrap.dart';
import 'package:tur_izim/core/di/tur_izim_dependencies.dart';
import 'package:tur_izim/features/applications/presentation/creator_my_applications_screen.dart';
import 'package:tur_izim/shared/models/user_role.dart';

import 'test_session_auth.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Başvurularım ekranında AUE satırı görünür', (tester) async {
    final session = createTestSessionAuthRepository();
    await session.selectRole(UserRole.creator);
    final api = HttpTurIzimApiClient();
    final bootstrap = TurIzimMockBootstrap.mockOnly();

    await tester.pumpWidget(
      MaterialApp(
        home: TurIzimScope(
          session: session,
          child: TurIzimDependencies(
            apiClient: api,
            tours: bootstrap.tours,
            applications: bootstrap.applications,
            assignments: bootstrap.assignments,
            deliveries: bootstrap.deliveries,
            publications: bootstrap.publications,
            violations: bootstrap.violations,
            creatorDashboard: bootstrap.creatorDashboard,
            agencyDashboard: bootstrap.agencyDashboard,
            adminDashboard: bootstrap.adminDashboard,
            aiMatch: bootstrap.aiMatch,
            billing: bootstrap.billing,
            child: const CreatorMyApplicationsScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Aday Uygunluk Endeksi'), findsWidgets);
  });
}
