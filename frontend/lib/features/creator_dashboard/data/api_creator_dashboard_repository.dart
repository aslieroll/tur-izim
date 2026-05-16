import 'package:tur_izim/core/api/api_client.dart';
import 'package:tur_izim/features/creator_dashboard/domain/creator_dashboard_repository.dart';
import 'package:tur_izim/shared/models/creator_home_peek.dart';

/// Sayım ve isim için doğrudan `/api/creators/...` uçları.
final class ApiCreatorDashboardRepository implements CreatorDashboardRepository {
  ApiCreatorDashboardRepository(this._api);

  final TurIzimApiClient _api;

  @override
  Future<CreatorHomePeek> loadHomePeek(String creatorId) async {
    final profile = await _api.getJson('/api/creators/$creatorId');
    final apps = await _api.getJsonList('/api/creators/$creatorId/applications');
    final asgs = await _api.getJsonList('/api/creators/$creatorId/assignments');

    var pendingApps = 0;
    for (final raw in apps) {
      final m = raw as Map<String, dynamic>;
      if (m['status']?.toString() == 'PENDING_REVIEW') pendingApps++;
    }

    var actionable = 0;
    for (final raw in asgs) {
      final m = raw as Map<String, dynamic>;
      final st = m['status']?.toString();
      if (st == 'PENDING_CREATOR_CONFIRMATION') {
        actionable++;
        continue;
      }
      final dep = m['deposit'];
      if (st == 'CONFIRMED' && dep is Map<String, dynamic> && dep['status']?.toString() == 'PENDING') {
        actionable++;
      }
    }

    final name = profile['fullName']?.toString() ?? 'Üretici';
    final uni = profile['universityName']?.toString();
    final city = profile['city']?.toString();
    String? line;
    if (uni != null && city != null) {
      line = '$uni · $city';
    } else {
      line = uni ?? city;
    }

    return CreatorHomePeek(
      pendingApplicationsCount: pendingApps,
      openAssignmentsNeedingAttentionCount: actionable,
      creatorDisplayName: name,
      studentProfilePreviewLine: line,
    );
  }
}
