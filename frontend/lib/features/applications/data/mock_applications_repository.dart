import 'package:tur_izim/core/mock/mock_tur_izim_store.dart';
import 'package:tur_izim/shared/models/application_commitment.dart';
import 'package:tur_izim/shared/models/application_status.dart';
import 'package:tur_izim/shared/models/application_summary.dart';
import 'package:tur_izim/shared/models/rated_application.dart';

import '../domain/applications_repository.dart';

final class MockApplicationsRepository implements ApplicationsRepository {
  MockApplicationsRepository(this._store);

  final MockTurIzimStore _store;

  @override
  Future<ApplicationSummary?> findByTourAndCreator({
    required String tourId,
    required String creatorId,
  }) async {
    final matches = _store
        .applicationsForCreator(creatorId)
        .where((element) => element.tourId == tourId)
        .where(
          (element) =>
              element.status != ApplicationStatus.withdrawn &&
              element.status != ApplicationStatus.rejected,
        )
        .toList();
    if (matches.isEmpty) {
      return null;
    }
    return matches.first;
  }

  @override
  Future<List<ApplicationSummary>> listByCreator(String creatorId) async {
    await Future<void>.delayed(const Duration(milliseconds: 30));
    return _store.applicationsForCreator(creatorId);
  }

  @override
  Future<List<RatedApplication>> listRatedApplicantsForTour({
    required String actingAgencyId,
    required String tourId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 40));
    return _store.ratedApplicantsForTour(
      actingAgencyId: actingAgencyId,
      tourId: tourId,
    );
  }

  @override
  Future<void> submitApplication({
    required String creatorId,
    required String tourId,
    required ApplicationCommitment commitment,
    String? message,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 55));
    await _store.submitApplication(
      creatorId: creatorId,
      tourId: tourId,
      commitment: commitment,
      message: message,
    );
  }

  @override
  Future<void> withdrawApplication({
    required String applicationId,
    required String creatorId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 45));
    await _store.withdrawApplication(
      creatorId: creatorId,
      applicationId: applicationId,
    );
  }
}
