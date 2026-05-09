import 'package:tur_izim/shared/models/application_commitment.dart';
import 'package:tur_izim/shared/models/assignment_detail.dart';
import 'package:tur_izim/shared/models/assignment_summary.dart';
import 'package:tur_izim/shared/models/assignment_timeline_step.dart';

abstract class AssignmentsRepository {
  Future<List<AssignmentSummary>> listByCreator(String creatorId);

  Future<List<AssignmentSummary>> listByTourForAgency({
    required String agencyId,
    required String tourId,
  });

  Future<AssignmentDetail?> loadAssignmentDetail({
    required String assignmentId,
    required String? viewerCreatorId,
    required String? viewerAgencyId,
  });

  Future<List<AssignmentTimelineStep>> loadTimeline({
    required String assignmentId,
    required String? viewerCreatorId,
    required String? viewerAgencyId,
  });

  Future<void> creatorConfirmDeposit({
    required String assignmentId,
    required String creatorId,
    required ApplicationCommitment commitment,
  });

  Future<void> agencyAcceptApplicants({
    required String actingAgencyId,
    required String tourId,
    required List<String> applicationIds,
  });

  /// Tek başvuru seçimi (mock); depozito / teslimat oluşturmaz.
  Future<void> agencySelectApplicant({
    required String actingAgencyId,
    required String tourId,
    required String applicationId,
  });
}
