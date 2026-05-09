import 'package:tur_izim/core/errors/app_exception.dart';
import 'package:tur_izim/core/mock/mock_tur_izim_store.dart';
import 'package:tur_izim/shared/models/application_commitment.dart';
import 'package:tur_izim/shared/models/assignment_detail.dart';
import 'package:tur_izim/shared/models/assignment_summary.dart';
import 'package:tur_izim/shared/models/assignment_timeline_step.dart';

import '../domain/assignments_repository.dart';

final class MockAssignmentsRepository implements AssignmentsRepository {
  MockAssignmentsRepository(this._store);

  final MockTurIzimStore _store;

  @override
  Future<void> agencyAcceptApplicants({
    required String actingAgencyId,
    required String tourId,
    required List<String> applicationIds,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 60));
    await _store.agencyAcceptApplicants(
      actingAgencyId: actingAgencyId,
      tourId: tourId,
      applicationIds: applicationIds,
    );
  }

  @override
  Future<void> agencySelectApplicant({
    required String actingAgencyId,
    required String tourId,
    required String applicationId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 60));
    await _store.agencySelectApplicant(
      actingAgencyId: actingAgencyId,
      tourId: tourId,
      applicationId: applicationId,
    );
  }

  @override
  Future<void> creatorConfirmDeposit({
    required String assignmentId,
    required String creatorId,
    required ApplicationCommitment commitment,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 60));
    await _store.creatorConfirmDeposit(
      assignmentId: assignmentId,
      creatorId: creatorId,
      commitment: commitment,
    );
  }

  @override
  Future<AssignmentDetail?> loadAssignmentDetail({
    required String assignmentId,
    required String? viewerCreatorId,
    required String? viewerAgencyId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 40));
    try {
      return _store.assignmentDetailForViewer(
        assignmentId: assignmentId,
        viewerCreatorId: viewerCreatorId,
        viewerAgencyId: viewerAgencyId,
      );
    } on AppException {
      return null;
    }
  }

  @override
  Future<List<AssignmentTimelineStep>> loadTimeline({
    required String assignmentId,
    required String? viewerCreatorId,
    required String? viewerAgencyId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 25));
    _store.assignmentDetailForViewer(
      assignmentId: assignmentId,
      viewerCreatorId: viewerCreatorId,
      viewerAgencyId: viewerAgencyId,
    );
    return _store.buildTimeline(assignmentId);
  }

  @override
  Future<List<AssignmentSummary>> listByCreator(String creatorId) async {
    await Future<void>.delayed(const Duration(milliseconds: 35));
    return _store.assignmentsForCreator(creatorId);
  }

  @override
  Future<List<AssignmentSummary>> listByTourForAgency({
    required String agencyId,
    required String tourId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 35));
    return _store.assignmentsForAgencyTour(agencyId: agencyId, tourId: tourId);
  }
}
