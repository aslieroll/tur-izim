import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/admin_dashboard/presentation/admin_panel_screen.dart';
import '../features/agency_dashboard/presentation/agency_board_screen.dart';
import '../features/applications/presentation/agency_tour_applicants_screen.dart';
import '../features/applications/presentation/creator_application_form_screen.dart';
import '../features/applications/presentation/creator_my_applications_screen.dart';
import '../features/assignments/presentation/creator_assignment_hub_screen.dart';
import '../features/assignments/presentation/creator_deposit_ack_screen.dart';
import '../features/assignments/presentation/creator_my_assignments_screen.dart';
import '../features/auth/data/session_auth_repository.dart';
import '../features/auth/presentation/welcome_screen.dart';
import '../features/publications/presentation/creator_submit_publication_screen.dart';
import '../features/tours/presentation/creator_open_tours_screen.dart';
import '../features/tours/presentation/creator_tour_detail_screen.dart';
import '../shared/models/user_role.dart';

/// Route path literals shared between navigation and redirects.
abstract final class AppRoutes {
  AppRoutes._();

  static const String welcome = '/';
  static const String creatorHome = '/creator';
  static const String agencyHome = '/agency';
  static const String adminHome = '/admin';

  /// Creator deep links (used by partial mock UI; shell routes may not all be wired).
  static String creatorTour(String tourId) => '/creator/tours/$tourId';

  static String creatorApply(String tourId) => '/creator/tours/$tourId/basvur';

  static const String creatorApplications = '/creator/applications';

  static const String creatorAssignments = '/creator/assignments';

  static String creatorAssignment(String assignmentId) =>
      '/creator/assignment/$assignmentId';

  static String creatorDeposit(String assignmentId) =>
      '/creator/assignment/$assignmentId/deposit-ack';

  static String creatorDraft(String assignmentId) =>
      '/creator/assignment/$assignmentId/draft';

  static String creatorPublication(String assignmentId) =>
      '/creator/assignment/$assignmentId/publication';

  /// Agency deep links.
  static String agencyApplicants(String tourId) =>
      '/agency/tours/$tourId/applicants';
}

GoRouter buildAppRouter(SessionAuthRepository session) {
  return GoRouter(
    refreshListenable: session,
    initialLocation: AppRoutes.welcome,
    redirect: (BuildContext _, GoRouterState state) {
      final path = state.matchedLocation;
      final role = session.currentRole;

      if (path == AppRoutes.welcome) {
        return null;
      }

      if (role == null) {
        return AppRoutes.welcome;
      }

      if (path.startsWith(AppRoutes.creatorHome) && role != UserRole.creator) {
        return AppRoutes.welcome;
      }
      if (path.startsWith(AppRoutes.agencyHome) && role != UserRole.agency) {
        return AppRoutes.welcome;
      }
      if (path.startsWith(AppRoutes.adminHome) && role != UserRole.admin) {
        return AppRoutes.welcome;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, _) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/creator/tours/:tourId/basvur',
        builder: (context, state) => CreatorApplicationFormScreen(
          tourId: state.pathParameters['tourId']!,
        ),
      ),
      GoRoute(
        path: '/creator/tours/:tourId',
        builder: (context, state) =>
            CreatorTourDetailScreen(tourId: state.pathParameters['tourId']!),
      ),
      GoRoute(
        path: AppRoutes.creatorApplications,
        builder: (_, _) => const CreatorMyApplicationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.creatorAssignments,
        builder: (_, _) => const CreatorMyAssignmentsScreen(),
      ),
      GoRoute(
        path: '/creator/assignment/:assignmentId',
        builder: (context, state) => CreatorAssignmentHubScreen(
          assignmentId: state.pathParameters['assignmentId']!,
        ),
      ),
      GoRoute(
        path: '/creator/assignment/:assignmentId/deposit-ack',
        builder: (context, state) => CreatorDepositAckScreen(
          assignmentId: state.pathParameters['assignmentId']!,
        ),
      ),
      GoRoute(
        path: '/creator/assignment/:assignmentId/publication',
        builder: (context, state) => CreatorSubmitPublicationScreen(
          assignmentId: state.pathParameters['assignmentId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.creatorHome,
        builder: (_, _) => const CreatorOpenToursScreen(),
      ),
      GoRoute(
        path: '/agency/tours/:tourId/applicants',
        builder: (context, state) =>
            AgencyTourApplicantsScreen(tourId: state.pathParameters['tourId']!),
      ),
      GoRoute(
        path: AppRoutes.agencyHome,
        builder: (_, _) => const AgencyBoardScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminHome,
        builder: (_, _) => const AdminPanelScreen(),
      ),
    ],
    errorBuilder: (_, _) => Scaffold(
      appBar: AppBar(title: const Text('Rota')),
      body: const Center(child: Text('Geçersiz rota')),
    ),
  );
}
