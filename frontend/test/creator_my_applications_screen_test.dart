import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tur_izim/app/tur_izim_scope.dart';
import 'package:tur_izim/core/bootstrap/tur_izim_mock_bootstrap.dart';
import 'package:tur_izim/core/di/tur_izim_dependencies.dart';
import 'package:tur_izim/features/applications/presentation/creator_my_applications_screen.dart';
import 'package:tur_izim/features/auth/data/session_auth_repository.dart';
import 'package:tur_izim/shared/models/user_role.dart';

void main() {
  testWidgets('Başvurularım ekranında AUE satırı görünür', (tester) async {
    final session = SessionAuthRepository();
    await session.selectRole(UserRole.creator);
    final bootstrap = TurIzimMockBootstrap();

    await tester.pumpWidget(
      MaterialApp(
        home: TurIzimScope(
          session: session,
          child: TurIzimDependencies(
            tours: bootstrap.tours,
            applications: bootstrap.applications,
            assignments: bootstrap.assignments,
            deliveries: bootstrap.deliveries,
            publications: bootstrap.publications,
            violations: bootstrap.violations,
            creatorDashboard: bootstrap.creatorDashboard,
            agencyDashboard: bootstrap.agencyDashboard,
            adminDashboard: bootstrap.adminDashboard,
            child: const CreatorMyApplicationsScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Aday Uygunluk Endeksi'), findsWidgets);
  });
}
