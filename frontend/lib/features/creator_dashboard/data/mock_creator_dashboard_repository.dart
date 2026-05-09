import 'package:tur_izim/core/mock/mock_tur_izim_store.dart';
import 'package:tur_izim/shared/models/creator_home_peek.dart';

import '../domain/creator_dashboard_repository.dart';

final class MockCreatorDashboardRepository
    implements CreatorDashboardRepository {
  MockCreatorDashboardRepository(this._store);

  final MockTurIzimStore _store;

  @override
  Future<CreatorHomePeek> loadHomePeek(String creatorId) async {
    await Future<void>.delayed(const Duration(milliseconds: 35));
    final profile = _store.creators[creatorId];
    final name = profile?.displayName.trim() ?? '';
    return CreatorHomePeek(
      pendingApplicationsCount: _store.pendingApplicationsForCreator(creatorId),
      openAssignmentsNeedingAttentionCount: _store.creatorActionableAssignments(
        creatorId,
      ),
      creatorDisplayName: name.isEmpty ? 'Üretici' : name,
      studentProfilePreviewLine: profile?.studentProfileLine,
    );
  }
}
