import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tur_izim/app/tur_izim_scope.dart';
import 'package:tur_izim/core/api/api_client.dart';
import 'package:tur_izim/core/bootstrap/tur_izim_mock_bootstrap.dart';
import 'package:tur_izim/core/di/tur_izim_dependencies.dart';
import 'package:tur_izim/features/agency_dashboard/presentation/agency_pro_package_card.dart';
import 'package:tur_izim/features/billing/domain/agency_plan.dart';
import 'package:tur_izim/features/billing/domain/agency_subscription.dart';
import 'package:tur_izim/shared/models/user_role.dart';
import 'package:tur_izim/shared/widgets/tur_izim_primary_button.dart';
import 'package:tur_izim/shared/widgets/tur_izim_status_pill.dart';

import 'test_session_auth.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestApp(Widget child) {
    final session = createTestSessionAuthRepository();
    session.selectRole(UserRole.agency);
    final api = HttpTurIzimApiClient();
    final bootstrap = TurIzimMockBootstrap.mockOnly();
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: TurIzimScope(
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
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('SubscriptionPlansSection renders 3 plan cards', (tester) async {
    await tester.pumpWidget(buildTestApp(
      SubscriptionPlansSection(subscription: AgencySubscription.free),
    ));
    await tester.pumpAndSettle();

    // Her iki plan kartı ASCII adı mevcut
    expect(find.text('Agency Pro'), findsWidgets);
    expect(find.text('Agency Growth'), findsWidgets);
  });

  testWidgets('SubscriptionPlansSection Pro active shows Mevcut Plan badge', (tester) async {
    await tester.pumpWidget(buildTestApp(
      SubscriptionPlansSection(subscription: AgencySubscription.mockActive),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Mevcut Plan'), findsOneWidget);
  });

  testWidgets('AgencyPlanCard FREE shows no CTA button', (tester) async {
    await tester.pumpWidget(buildTestApp(
      AgencyPlanCard(
        plan: AgencyPlan.staticPlans.first,
        currentPlanCode: 'FREE',
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(TurIzimPrimaryButton), findsNothing);
  });

  testWidgets('AgencyPlanCard Pro shows CTA button', (tester) async {
    final proPlan = AgencyPlan.staticPlans.firstWhere((p) => p.planCode == 'AGENCY_PRO');
    await tester.pumpWidget(buildTestApp(
      AgencyPlanCard(plan: proPlan, currentPlanCode: 'FREE'),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(TurIzimPrimaryButton), findsOneWidget);
  });

  testWidgets('AgencyPlanCard Growth shows recommended status pill', (tester) async {
    final growthPlan = AgencyPlan.staticPlans.firstWhere((p) => p.planCode == 'AGENCY_GROWTH');
    await tester.pumpWidget(buildTestApp(
      AgencyPlanCard(plan: growthPlan, currentPlanCode: 'FREE'),
    ));
    await tester.pumpAndSettle();

    // Growth card not current -> shows recommended pill, not Mevcut Plan
    expect(find.byType(TurIzimStatusPill), findsOneWidget);
    expect(find.text('Mevcut Plan'), findsNothing);
  });

  testWidgets('AgencyPlan model - FREE isFree true', (_) async {
    expect(AgencyPlan.staticPlans.first.isFree, isTrue);
  });

  testWidgets('AgencySubscription free - isPaid false', (_) async {
    expect(AgencySubscription.free.isPaid, isFalse);
  });

  testWidgets('AgencySubscription mockActive - isPaid true', (_) async {
    expect(AgencySubscription.mockActive.isPaid, isTrue);
  });

  testWidgets('AgencyPlan.staticPlans has 3 plans', (_) async {
    expect(AgencyPlan.staticPlans.length, 3);
    expect(AgencyPlan.staticPlans[0].planCode, 'FREE');
    expect(AgencyPlan.staticPlans[1].planCode, 'AGENCY_PRO');
    expect(AgencyPlan.staticPlans[2].planCode, 'AGENCY_GROWTH');
  });

  testWidgets('Plan limits match business rules', (_) async {
    expect(AgencyPlan.staticPlans[0].activeTourLimit, 1);
    expect(AgencyPlan.staticPlans[1].activeTourLimit, 5);
    expect(AgencyPlan.staticPlans[2].activeTourLimit, 20);
  });

  testWidgets('Free plan has no paid features', (_) async {
    final free = AgencyPlan.staticPlans[0];
    expect(free.canUseAiMatch, isFalse);
    expect(free.canManageApplicants, isFalse);
    expect(free.canSelectCreator, isFalse);
  });

  testWidgets('Pro plan has all paid features', (_) async {
    final pro = AgencyPlan.staticPlans[1];
    expect(pro.canUseAiMatch, isTrue);
    expect(pro.canManageApplicants, isTrue);
    expect(pro.canSelectCreator, isTrue);
  });

  testWidgets('Growth plan has priority support', (_) async {
    final growth = AgencyPlan.staticPlans[2];
    expect(growth.prioritySupport, isTrue);
  });
}
