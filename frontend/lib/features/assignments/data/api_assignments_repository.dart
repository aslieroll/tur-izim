import 'package:tur_izim/core/api/api_client.dart';
import 'package:tur_izim/core/api/api_exception.dart';
import 'package:tur_izim/core/api/backend_dto_mappers.dart';
import 'package:tur_izim/core/errors/app_exception.dart';
import 'package:tur_izim/features/assignments/domain/assignments_repository.dart';
import 'package:tur_izim/features/tours/domain/tour_repository.dart';
import 'package:tur_izim/shared/models/application_commitment.dart';
import 'package:tur_izim/shared/models/assignment_detail.dart';
import 'package:tur_izim/shared/models/assignment_status.dart';
import 'package:tur_izim/shared/models/assignment_summary.dart';
import 'package:tur_izim/shared/models/assignment_timeline_step.dart';
import 'package:tur_izim/shared/models/mock_deposit_status.dart';
import 'package:tur_izim/shared/models/tour_detail.dart';

final class ApiAssignmentsRepository implements AssignmentsRepository {
  ApiAssignmentsRepository(this._api, this._tours);

  final TurIzimApiClient _api;
  final TourRepository _tours;

  @override
  Future<void> agencyAcceptApplicants({
    required String actingAgencyId,
    required String tourId,
    required List<String> applicationIds,
  }) async {
    throw AppException('Çoklu kabul bu API diliminde yok; adayları tek tek seçin.');
  }

  @override
  Future<void> agencySelectApplicant({
    required String actingAgencyId,
    required String tourId,
    required String applicationId,
  }) async {
    await _api.postJson('/api/applications/$applicationId/select', {});
  }

  @override
  Future<void> creatorConfirmDeposit({
    required String assignmentId,
    required String creatorId,
    required ApplicationCommitment commitment,
  }) async {
    if (!commitment.isComplete) {
      throw AppException('Taahhüt kutularının tamamı işaretlenmelidir.');
    }
    await _api.postJson('/api/assignments/$assignmentId/confirm', {});
  }

  @override
  Future<AssignmentDetail?> loadAssignmentDetail({
    required String assignmentId,
    required String? viewerCreatorId,
    required String? viewerAgencyId,
  }) async {
    try {
      final j = await _api.getJson('/api/assignments/$assignmentId');
      final tourId = j['tourId']?.toString();
      if (tourId == null) return null;
      final TourDetail? tour = await _tours.fetchTourDetail(tourId);
      if (tour == null) return null;

      final summary = assignmentSummaryFromListJson(j);
      final aid = j['id'].toString();
      final cid = j['creatorId'].toString();
      final agid = j['agencyId'].toString();
      final deposit = mockDepositFromEmbeddedJson(j, aid, tourId, cid, agid);

      final pubRaw = await _api.getJsonOrNull('/api/assignments/$assignmentId/publication-proof');
      final publication = pubRaw != null ? publicationRecordFromBackendJson(pubRaw, aid) : null;

      final confirmedAt = j['creatorConfirmedAt']?.toString();
      return AssignmentDetail(
        summary: summary,
        tour: tour,
        deposit: deposit,
        delivery: null,
        publication: publication,
        creatorDepositAcknowledgedAt:
            confirmedAt != null && confirmedAt.isNotEmpty ? DateTime.tryParse(confirmedAt) : null,
        applicationMessage: null,
      );
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<List<AssignmentTimelineStep>> loadTimeline({
    required String assignmentId,
    required String? viewerCreatorId,
    required String? viewerAgencyId,
  }) async {
    final detail = await loadAssignmentDetail(
      assignmentId: assignmentId,
      viewerCreatorId: viewerCreatorId,
      viewerAgencyId: viewerAgencyId,
    );
    if (detail == null) return const [];
    return _syntheticTimeline(detail);
  }

  List<AssignmentTimelineStep> _syntheticTimeline(AssignmentDetail d) {
    final st = d.summary.status;
    final dep = d.deposit?.status;
    final creatorOk = d.creatorDepositAcknowledgedAt != null;
    final awaitingCreator = st == AssignmentStatus.awaitingCreatorConfirmation;
    final depositPending = st == AssignmentStatus.pendingDeposit && dep == MockDepositStatus.pending;
    final depositHeld = dep == MockDepositStatus.held;

    return [
      AssignmentTimelineStep(
        phase: AssignmentTimelinePhase.awaitingCreatorConfirmation,
        label: 'Acente seçimi / üretici kesin onayı',
        isComplete: !awaitingCreator,
        timestamp: null,
      ),
      AssignmentTimelineStep(
        phase: AssignmentTimelinePhase.awaitingDepositConfirmation,
        label: 'Mock depozito (MVP)',
        isComplete: depositHeld || creatorOk || (!depositPending && !awaitingCreator),
        timestamp: d.creatorDepositAcknowledgedAt,
      ),
      AssignmentTimelineStep(
        phase: AssignmentTimelinePhase.awaitingPublicationSubmission,
        label: 'Yayın bağlantısı',
        isComplete: d.publication != null && d.publication!.publishedUrl != null,
        timestamp: d.publication?.submittedAt,
      ),
    ];
  }

  @override
  Future<List<AssignmentSummary>> listByCreator(String creatorId) async {
    final list = await _api.getJsonList('/api/creators/$creatorId/assignments');
    return list
        .map((e) => assignmentSummaryFromListJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<AssignmentSummary>> listByTourForAgency({
    required String agencyId,
    required String tourId,
  }) async {
    // Backend MVP’de acente+tur filtresi yok; boş liste (UI atama bölümü boş kalır).
    return const [];
  }
}
