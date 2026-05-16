import 'package:tur_izim/core/api/api_client.dart';
import 'package:tur_izim/core/bootstrap/resilient_repository_wrappers.dart';
import 'package:tur_izim/core/mock/mock_tur_izim_store.dart';
import 'package:tur_izim/features/admin_dashboard/data/mock_admin_dashboard_repository.dart';
import 'package:tur_izim/features/admin_dashboard/domain/admin_dashboard_repository.dart';
import 'package:tur_izim/features/agency_dashboard/data/api_agency_dashboard_repository.dart';
import 'package:tur_izim/features/agency_dashboard/data/mock_agency_dashboard_repository.dart';
import 'package:tur_izim/features/agency_dashboard/domain/agency_dashboard_repository.dart';
import 'package:tur_izim/features/applications/data/api_applications_repository.dart';
import 'package:tur_izim/features/applications/data/mock_applications_repository.dart';
import 'package:tur_izim/features/applications/domain/applications_repository.dart';
import 'package:tur_izim/features/assignments/data/api_assignments_repository.dart';
import 'package:tur_izim/features/assignments/data/mock_assignments_repository.dart';
import 'package:tur_izim/features/assignments/domain/assignments_repository.dart';
import 'package:tur_izim/features/creator_dashboard/data/api_creator_dashboard_repository.dart';
import 'package:tur_izim/features/creator_dashboard/data/mock_creator_dashboard_repository.dart';
import 'package:tur_izim/features/creator_dashboard/domain/creator_dashboard_repository.dart';
import 'package:tur_izim/features/deliveries/data/mock_deliveries_repository.dart';
import 'package:tur_izim/features/deliveries/domain/deliveries_repository.dart';
import 'package:tur_izim/features/publications/data/api_publications_repository.dart';
import 'package:tur_izim/features/publications/data/mock_publications_repository.dart';
import 'package:tur_izim/features/publications/domain/publications_repository.dart';
import 'package:tur_izim/features/tours/data/api_tour_repository.dart';
import 'package:tur_izim/features/tours/data/mock_tour_repository.dart';
import 'package:tur_izim/features/tours/domain/tour_repository.dart';
import 'package:tur_izim/features/violations/data/mock_violations_repository.dart';
import 'package:tur_izim/features/violations/domain/violations_repository.dart';

/// Koordineli mock depolar — üretimde API + mock fallback; **widget/unit test** için {@link mockOnly}.
final class TurIzimMockBootstrap {
  /// `HttpTurIzimApiClient` + dayanıklı repository (backend kapalıysa mock).
  TurIzimMockBootstrap({required TurIzimApiClient apiClient}) : store = MockTurIzimStore() {
    final apiTourOnly = ApiTourRepository(apiClient);
    final mockTour = MockTourRepository(store);
    tours = ResilientTourRepository(api: apiTourOnly, mock: mockTour);

    final mockApplications = MockApplicationsRepository(store);
    applications = ResilientApplicationsRepository(
      api: ApiApplicationsRepository(apiClient),
      mock: mockApplications,
    );

    final mockAssignments = MockAssignmentsRepository(store);
    assignments = ResilientAssignmentsRepository(
      api: ApiAssignmentsRepository(apiClient, apiTourOnly),
      mock: mockAssignments,
    );

    deliveries = MockDeliveriesRepository(store);

    final mockPublications = MockPublicationsRepository(store);
    publications = ResilientPublicationsRepository(
      api: ApiPublicationsRepository(apiClient),
      mock: mockPublications,
    );

    violations = MockViolationsRepository(store);

    final mockCreatorHome = MockCreatorDashboardRepository(store);
    creatorDashboard = ResilientCreatorDashboardRepository(
      api: ApiCreatorDashboardRepository(apiClient),
      mock: mockCreatorHome,
    );

    agencyDashboard = ResilientAgencyDashboardRepository(
      api: ApiAgencyDashboardRepository(apiClient),
      mock: MockAgencyDashboardRepository(store),
    );
    adminDashboard = MockAdminDashboardRepository(store);
  }

  /// Flutter `test` ortamında `http` 400 sahte cevap verir; bu fabrika yalnızca mock kullanır.
  TurIzimMockBootstrap.mockOnly() : store = MockTurIzimStore() {
    tours = MockTourRepository(store);
    applications = MockApplicationsRepository(store);
    assignments = MockAssignmentsRepository(store);
    deliveries = MockDeliveriesRepository(store);
    publications = MockPublicationsRepository(store);
    violations = MockViolationsRepository(store);
    creatorDashboard = MockCreatorDashboardRepository(store);
    agencyDashboard = MockAgencyDashboardRepository(store);
    adminDashboard = MockAdminDashboardRepository(store);
  }

  final MockTurIzimStore store;

  late final TourRepository tours;
  late final ApplicationsRepository applications;
  late final AssignmentsRepository assignments;
  late final DeliveriesRepository deliveries;
  late final PublicationsRepository publications;
  late final ViolationsRepository violations;
  late final CreatorDashboardRepository creatorDashboard;
  late final AgencyDashboardRepository agencyDashboard;
  late final AdminDashboardRepository adminDashboard;
}
