import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tur_izim/app/tur_izim_scope.dart';
import 'package:tur_izim/core/api/api_client.dart';
import 'package:tur_izim/core/bootstrap/tur_izim_mock_bootstrap.dart';
import 'package:tur_izim/core/constants/mock_actor_ids.dart';
import 'package:tur_izim/core/di/tur_izim_dependencies.dart';
import 'package:tur_izim/features/applications/presentation/agency_tour_applicants_screen.dart';
import 'package:tur_izim/shared/models/user_role.dart';

import 'test_session_auth.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Acente başvuran listesi AUE ve üretici adı gösterir', (
    tester,
  ) async {
    final session = createTestSessionAuthRepository();
    await session.selectRole(UserRole.agency);
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
            child: AgencyTourApplicantsScreen(
              tourId: MockActorIds.tourKapadokya,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(
      find.descendant(
        of: find.byType(AgencyTourApplicantsScreen),
        matching: find.byType(CustomScrollView),
      ),
      const Offset(0, -1000),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Aday Uygunluk Endeksi'), findsWidgets);
    expect(find.textContaining('Ayşe'), findsWidgets);
    expect(find.textContaining('Kapadokya'), findsWidgets);
    expect(
      find.text('Başvuran Öğrenci İçerik Üreticileri'),
      findsOneWidget,
    );
    expect(find.text('Adayı İncele'), findsWidgets);
    expect(find.text('Seçimi Onayla'), findsWidgets);
    expect(find.text('AI Eşleşme Asistanı'), findsWidgets);
    expect(find.textContaining('Uygunluk:'), findsWidgets);
  });

  testWidgets('Başvurusuz ilanda boş durum', (tester) async {
    final session = createTestSessionAuthRepository();
    await session.selectRole(UserRole.agency);
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
            child: AgencyTourApplicantsScreen(
              tourId: MockActorIds.tourAntalyaCoast,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bu ilana henüz başvuru yok.'), findsOneWidget);
  });
}
