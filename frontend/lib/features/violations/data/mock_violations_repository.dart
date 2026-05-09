import 'package:tur_izim/core/mock/mock_tur_izim_store.dart';
import 'package:tur_izim/shared/models/violation_report.dart';

import '../domain/violations_repository.dart';

final class MockViolationsRepository implements ViolationsRepository {
  MockViolationsRepository(this._store);

  final MockTurIzimStore _store;

  @override
  Future<void> createViolationReport({
    required String assignmentId,
    required String publicationId,
    required String reporterAgencyId,
    required String reason,
    String? evidenceUrl,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 45));
    await _store.agencyReportViolation(
      actingAgencyId: reporterAgencyId,
      assignmentId: assignmentId,
      publicationId: publicationId,
      reason: reason,
      evidenceUrl: evidenceUrl,
    );
  }

  @override
  Future<List<ViolationReport>> listForAdmin() async {
    await Future<void>.delayed(const Duration(milliseconds: 35));
    return _store.violationsForAdmin();
  }

  @override
  Future<void> resolveByAdmin({
    required String violationId,
    required String resolutionNote,
    required bool confirmViolation,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 40));
    await _store.adminResolveViolation(
      violationId: violationId,
      resolutionNote: resolutionNote,
      confirmViolation: confirmViolation,
    );
  }
}
