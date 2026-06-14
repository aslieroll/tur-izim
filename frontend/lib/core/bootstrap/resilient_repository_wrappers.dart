import 'package:tur_izim/core/api/api_exception.dart';
import 'package:tur_izim/core/api/api_fallback.dart';
import 'package:tur_izim/core/constants/mock_actor_ids.dart';
import 'package:tur_izim/core/errors/app_exception.dart';
import 'package:tur_izim/features/agency_dashboard/domain/agency_board_snapshot.dart';
import 'package:tur_izim/features/agency_dashboard/domain/agency_dashboard_repository.dart';
import 'package:tur_izim/features/ai_match/domain/ai_match_repository.dart';
import 'package:tur_izim/features/billing/domain/agency_plan.dart';
import 'package:tur_izim/features/billing/domain/agency_subscription.dart';
import 'package:tur_izim/features/billing/domain/billing_repository.dart';
import 'package:tur_izim/features/applications/domain/applications_repository.dart';
import 'package:tur_izim/features/assignments/domain/assignments_repository.dart';
import 'package:tur_izim/features/creator_dashboard/domain/creator_dashboard_repository.dart';
import 'package:tur_izim/features/publications/domain/publications_repository.dart';
import 'package:tur_izim/features/tours/domain/tour_repository.dart';
import 'package:tur_izim/shared/models/application_commitment.dart';
import 'package:tur_izim/shared/models/application_summary.dart';
import 'package:tur_izim/shared/models/assignment_detail.dart';
import 'package:tur_izim/shared/models/assignment_summary.dart';
import 'package:tur_izim/shared/models/assignment_timeline_step.dart';
import 'package:tur_izim/shared/models/creator_home_peek.dart';
import 'package:tur_izim/shared/models/publication_record.dart';
import 'package:tur_izim/shared/models/rated_application.dart';
import 'package:tur_izim/shared/models/tour_detail.dart';
import 'package:tur_izim/shared/models/tour_summary.dart';

final class ResilientTourRepository implements TourRepository {
  ResilientTourRepository({required TourRepository api, required TourRepository mock})
      : _api = api,
        _mock = mock;

  final TourRepository _api;
  final TourRepository _mock;

  @override
  Future<List<TourSummary>> fetchAgencyTours(String agencyId) => runWithApiFallback(
        tryApi: () => _api.fetchAgencyTours(agencyId),
        fallback: () => _mock.fetchAgencyTours(agencyId),
      );

  @override
  Future<TourDetail?> fetchTourDetail(String id) => runWithApiFallback(
        tryApi: () => _api.fetchTourDetail(id),
        fallback: () => _mock.fetchTourDetail(id),
      );

  @override
  Future<List<TourSummary>> fetchPublishedTours() => runWithApiFallback(
        tryApi: _api.fetchPublishedTours,
        fallback: _mock.fetchPublishedTours,
      );

  @override
  Future<List<TourSummary>> fetchPublishedToursForCreator(String creatorId) => runWithApiFallback(
        tryApi: () => _api.fetchPublishedToursForCreator(creatorId),
        fallback: () => _mock.fetchPublishedToursForCreator(creatorId),
      );

  @override
  Future<bool> hasCreatorApplied({
    required String tourId,
    required String creatorId,
  }) =>
      runWithApiFallback(
        tryApi: () => _api.hasCreatorApplied(tourId: tourId, creatorId: creatorId),
        fallback: () => _mock.hasCreatorApplied(tourId: tourId, creatorId: creatorId),
      );

  @override
  Future<bool> isCreatorEligibleForTour({
    required String creatorId,
    required String tourId,
  }) =>
      runWithApiFallback(
        tryApi: () => _api.isCreatorEligibleForTour(creatorId: creatorId, tourId: tourId),
        fallback: () => _mock.isCreatorEligibleForTour(creatorId: creatorId, tourId: tourId),
      );
}

final class ResilientApplicationsRepository implements ApplicationsRepository {
  ResilientApplicationsRepository({
    required ApplicationsRepository api,
    required ApplicationsRepository mock,
  })  : _api = api,
        _mock = mock;

  final ApplicationsRepository _api;
  final ApplicationsRepository _mock;

  @override
  Future<ApplicationSummary?> findByTourAndCreator({
    required String tourId,
    required String creatorId,
  }) =>
      runWithApiFallback(
        tryApi: () => _api.findByTourAndCreator(tourId: tourId, creatorId: creatorId),
        fallback: () => _mock.findByTourAndCreator(tourId: tourId, creatorId: creatorId),
      );

  @override
  Future<List<ApplicationSummary>> listByCreator(String creatorId) => runWithApiFallback(
        tryApi: () => _api.listByCreator(creatorId),
        fallback: () => _mock.listByCreator(creatorId),
      );

  @override
  Future<List<RatedApplication>> listRatedApplicantsForTour({
    required String actingAgencyId,
    required String tourId,
  }) =>
      runWithApiFallback(
        tryApi: () =>
            _api.listRatedApplicantsForTour(actingAgencyId: actingAgencyId, tourId: tourId),
        fallback: () =>
            _mock.listRatedApplicantsForTour(actingAgencyId: actingAgencyId, tourId: tourId),
      );

  @override
  Future<void> submitApplication({
    required String creatorId,
    required String tourId,
    required ApplicationCommitment commitment,
    String? message,
  }) =>
      runWithApiFallback(
        tryApi: () => _api.submitApplication(
          creatorId: creatorId,
          tourId: tourId,
          commitment: commitment,
          message: message,
        ),
        fallback: () => _mock.submitApplication(
          creatorId: creatorId,
          tourId: tourId,
          commitment: commitment,
          message: message,
        ),
      );

  @override
  Future<void> withdrawApplication({
    required String applicationId,
    required String creatorId,
  }) async {
    try {
      await _api.withdrawApplication(
        applicationId: applicationId,
        creatorId: creatorId,
      );
    } on ApiException catch (e) {
      if (e.isConnectivityOrServerGap) {
        await _mock.withdrawApplication(
          applicationId: applicationId,
          creatorId: creatorId,
        );
        return;
      }
      rethrow;
    } on AppException {
      rethrow;
    }
  }
}

final class ResilientAssignmentsRepository implements AssignmentsRepository {
  ResilientAssignmentsRepository({
    required AssignmentsRepository api,
    required AssignmentsRepository mock,
  })  : _api = api,
        _mock = mock;

  final AssignmentsRepository _api;
  final AssignmentsRepository _mock;

  @override
  Future<void> agencyAcceptApplicants({
    required String actingAgencyId,
    required String tourId,
    required List<String> applicationIds,
  }) =>
      runWithApiFallback(
        tryApi: () => _api.agencyAcceptApplicants(
          actingAgencyId: actingAgencyId,
          tourId: tourId,
          applicationIds: applicationIds,
        ),
        fallback: () => _mock.agencyAcceptApplicants(
          actingAgencyId: actingAgencyId,
          tourId: tourId,
          applicationIds: applicationIds,
        ),
      );

  @override
  Future<void> agencySelectApplicant({
    required String actingAgencyId,
    required String tourId,
    required String applicationId,
  }) =>
      runWithApiFallback(
        tryApi: () => _api.agencySelectApplicant(
          actingAgencyId: actingAgencyId,
          tourId: tourId,
          applicationId: applicationId,
        ),
        fallback: () => _mock.agencySelectApplicant(
          actingAgencyId: actingAgencyId,
          tourId: tourId,
          applicationId: applicationId,
        ),
      );

  @override
  Future<void> creatorConfirmDeposit({
    required String assignmentId,
    required String creatorId,
    required ApplicationCommitment commitment,
  }) =>
      runWithApiFallback(
        tryApi: () => _api.creatorConfirmDeposit(
          assignmentId: assignmentId,
          creatorId: creatorId,
          commitment: commitment,
        ),
        fallback: () => _mock.creatorConfirmDeposit(
          assignmentId: assignmentId,
          creatorId: creatorId,
          commitment: commitment,
        ),
      );

  @override
  Future<AssignmentDetail?> loadAssignmentDetail({
    required String assignmentId,
    required String? viewerCreatorId,
    required String? viewerAgencyId,
  }) =>
      runWithApiFallback(
        tryApi: () => _api.loadAssignmentDetail(
          assignmentId: assignmentId,
          viewerCreatorId: viewerCreatorId,
          viewerAgencyId: viewerAgencyId,
        ),
        fallback: () => _mock.loadAssignmentDetail(
          assignmentId: assignmentId,
          viewerCreatorId: viewerCreatorId,
          viewerAgencyId: viewerAgencyId,
        ),
      );

  @override
  Future<List<AssignmentTimelineStep>> loadTimeline({
    required String assignmentId,
    required String? viewerCreatorId,
    required String? viewerAgencyId,
  }) =>
      runWithApiFallback(
        tryApi: () => _api.loadTimeline(
          assignmentId: assignmentId,
          viewerCreatorId: viewerCreatorId,
          viewerAgencyId: viewerAgencyId,
        ),
        fallback: () => _mock.loadTimeline(
          assignmentId: assignmentId,
          viewerCreatorId: viewerCreatorId,
          viewerAgencyId: viewerAgencyId,
        ),
      );

  @override
  Future<List<AssignmentSummary>> listByCreator(String creatorId) => runWithApiFallback(
        tryApi: () => _api.listByCreator(creatorId),
        fallback: () => _mock.listByCreator(creatorId),
      );

  @override
  Future<List<AssignmentSummary>> listByTourForAgency({
    required String agencyId,
    required String tourId,
  }) =>
      runWithApiFallback(
        tryApi: () => _api.listByTourForAgency(agencyId: agencyId, tourId: tourId),
        fallback: () => _mock.listByTourForAgency(agencyId: agencyId, tourId: tourId),
      );
}

final class ResilientPublicationsRepository implements PublicationsRepository {
  ResilientPublicationsRepository({
    required PublicationsRepository api,
    required PublicationsRepository mock,
  })  : _api = api,
        _mock = mock;

  final PublicationsRepository _api;
  final PublicationsRepository _mock;

  @override
  Future<PublicationRecord?> fetchForAssignment(String assignmentId) => runWithApiFallback(
        tryApi: () => _api.fetchForAssignment(assignmentId),
        fallback: () => _mock.fetchForAssignment(assignmentId),
      );

  @override
  Future<void> submitPublicationUrl({
    required String assignmentId,
    required String creatorId,
    required String publishedUrl,
  }) =>
      runWithApiFallback(
        tryApi: () => _api.submitPublicationUrl(
          assignmentId: assignmentId,
          creatorId: creatorId,
          publishedUrl: publishedUrl,
        ),
        fallback: () => _mock.submitPublicationUrl(
          assignmentId: assignmentId,
          creatorId: creatorId,
          publishedUrl: publishedUrl,
        ),
      );

  @override
  Future<void> agencyVerifyPublication({
    required String assignmentId,
    required String actingAgencyId,
  }) =>
      runWithApiFallback(
        tryApi: () =>
            _api.agencyVerifyPublication(assignmentId: assignmentId, actingAgencyId: actingAgencyId),
        fallback: () => _mock.agencyVerifyPublication(
          assignmentId: assignmentId,
          actingAgencyId: actingAgencyId,
        ),
      );
}

final class ResilientAgencyDashboardRepository implements AgencyDashboardRepository {
  ResilientAgencyDashboardRepository({
    required AgencyDashboardRepository api,
    required AgencyDashboardRepository mock,
  })  : _api = api,
        _mock = mock;

  final AgencyDashboardRepository _api;
  final AgencyDashboardRepository _mock;

  /// Backend kapalıyken örnek veri: mock store yalnızca [MockActorIds.approvedAgency] ile dolu.
  @override
  Future<AgencyBoardSnapshot> loadAgencyBoard(String agencyId) => runWithApiFallback(
        tryApi: () => _api.loadAgencyBoard(agencyId),
        fallback: () => _mock.loadAgencyBoard(MockActorIds.approvedAgency),
      );
}

final class ResilientCreatorDashboardRepository implements CreatorDashboardRepository {
  ResilientCreatorDashboardRepository({
    required CreatorDashboardRepository api,
    required CreatorDashboardRepository mock,
  })  : _api = api,
        _mock = mock;

  final CreatorDashboardRepository _api;
  final CreatorDashboardRepository _mock;

  @override
  Future<CreatorHomePeek> loadHomePeek(String creatorId) => runWithApiFallback(
        tryApi: () => _api.loadHomePeek(creatorId),
        fallback: () => _mock.loadHomePeek(creatorId),
      );
}

final class ResilientAiMatchRepository implements AiMatchRepository {
  ResilientAiMatchRepository({
    required AiMatchRepository api,
    required AiMatchRepository mock,
  })  : _api = api,
        _mock = mock;

  final AiMatchRepository _api;
  final AiMatchRepository _mock;

  @override
  Future<AiMatchResult> evaluateMatch({
    required String tourId,
    required String creatorId,
  }) =>
      runWithApiFallback(
        tryApi: () => _api.evaluateMatch(tourId: tourId, creatorId: creatorId),
        fallback: () => _mock.evaluateMatch(tourId: tourId, creatorId: creatorId),
      );
}

final class ResilientBillingRepository implements BillingRepository {
  ResilientBillingRepository({
    required BillingRepository api,
    required BillingRepository mock,
  })  : _api = api,
        _mock = mock;

  final BillingRepository _api;
  final BillingRepository _mock;

  @override
  Future<AgencySubscription> getSubscription(String agencyId) => runWithApiFallback(
        tryApi: () => _api.getSubscription(agencyId),
        fallback: () => _mock.getSubscription(agencyId),
      );

  @override
  Future<List<AgencyPlan>> getPlans() => runWithApiFallback(
        tryApi: _api.getPlans,
        fallback: _mock.getPlans,
      );

  @override
  Future<String?> getCheckoutUrl(String agencyId, String planCode) => runWithApiFallback(
        tryApi: () => _api.getCheckoutUrl(agencyId, planCode),
        fallback: () => _mock.getCheckoutUrl(agencyId, planCode),
      );
}
