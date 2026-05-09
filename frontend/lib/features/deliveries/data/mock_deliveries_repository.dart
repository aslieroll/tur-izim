import 'package:tur_izim/core/mock/mock_tur_izim_store.dart';
import 'package:tur_izim/shared/models/content_delivery.dart';

import '../domain/deliveries_repository.dart';

final class MockDeliveriesRepository implements DeliveriesRepository {
  MockDeliveriesRepository(this._store);

  final MockTurIzimStore _store;

  @override
  Future<void> approveDraft({
    required String assignmentId,
    required String actingAgencyId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 45));
    await _store.agencyApproveDraft(
      assignmentId: assignmentId,
      actingAgencyId: actingAgencyId,
    );
  }

  @override
  Future<ContentDelivery?> fetchLatestDelivery(String assignmentId) async {
    await Future<void>.delayed(const Duration(milliseconds: 25));
    return _store.deliverySnapshot(assignmentId);
  }

  @override
  Future<void> requestTechnicalRevision({
    required String assignmentId,
    required String actingAgencyId,
    required String checklistNotes,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 45));
    await _store.agencyRequestRevision(
      assignmentId: assignmentId,
      actingAgencyId: actingAgencyId,
      checklistNotes: checklistNotes,
    );
  }

  @override
  Future<void> submitDraftUrl({
    required String assignmentId,
    required String creatorId,
    required String url,
    String? notes,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 45));
    await _store.submitDraftUrl(
      assignmentId: assignmentId,
      creatorId: creatorId,
      url: url,
      notes: notes,
    );
  }
}
