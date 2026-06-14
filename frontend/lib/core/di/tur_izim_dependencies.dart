import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../features/admin_dashboard/domain/admin_dashboard_repository.dart';
import '../../features/agency_dashboard/domain/agency_dashboard_repository.dart';
import '../../features/ai_match/domain/ai_match_repository.dart';
import '../../features/applications/domain/applications_repository.dart';
import '../../features/billing/domain/billing_repository.dart';
import '../../features/assignments/domain/assignments_repository.dart';
import '../../features/creator_dashboard/domain/creator_dashboard_repository.dart';
import '../../features/deliveries/domain/deliveries_repository.dart';
import '../../features/publications/domain/publications_repository.dart';
import '../../features/tours/domain/tour_repository.dart';
import '../../features/violations/domain/violations_repository.dart';

/// Composition root for repositories (mock / API gelecek).
class TurIzimDependencies extends InheritedWidget {
  const TurIzimDependencies({
    required this.apiClient,
    required this.tours,
    required this.applications,
    required this.assignments,
    required this.deliveries,
    required this.publications,
    required this.violations,
    required this.creatorDashboard,
    required this.agencyDashboard,
    required this.adminDashboard,
    required this.aiMatch,
    required this.billing,
    required super.child,
    super.key,
  });

  final TurIzimApiClient apiClient;
  final TourRepository tours;
  final ApplicationsRepository applications;
  final AssignmentsRepository assignments;
  final DeliveriesRepository deliveries;
  final PublicationsRepository publications;
  final ViolationsRepository violations;
  final CreatorDashboardRepository creatorDashboard;
  final AgencyDashboardRepository agencyDashboard;
  final AdminDashboardRepository adminDashboard;
  final AiMatchRepository aiMatch;
  final BillingRepository billing;

  static TurIzimDependencies of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<TurIzimDependencies>();
    assert(scope != null, 'TurIzimDependencies not found');
    return scope!;
  }

  @override
  bool updateShouldNotify(TurIzimDependencies oldWidget) => false;
}
