import 'package:tur_izim/shared/models/application_commitment.dart';
import 'package:tur_izim/shared/models/application_summary.dart';
import 'package:tur_izim/shared/models/rated_application.dart';

abstract class ApplicationsRepository {
  Future<List<ApplicationSummary>> listByCreator(String creatorId);

  Future<List<RatedApplication>> listRatedApplicantsForTour({
    required String actingAgencyId,
    required String tourId,
  });

  Future<ApplicationSummary?> findByTourAndCreator({
    required String tourId,
    required String creatorId,
  });

  Future<void> submitApplication({
    required String creatorId,
    required String tourId,
    required ApplicationCommitment commitment,
    String? message,
  });

  Future<void> withdrawApplication({
    required String applicationId,
    required String creatorId,
  });
}
