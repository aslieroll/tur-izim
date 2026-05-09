/// Lightweight aggregate stub for creator home dashboards.
class CreatorHomePeek {
  const CreatorHomePeek({
    required this.pendingApplicationsCount,
    required this.openAssignmentsNeedingAttentionCount,
    required this.creatorDisplayName,
    this.studentProfilePreviewLine,
  });

  final int pendingApplicationsCount;
  final int openAssignmentsNeedingAttentionCount;

  /// Mock profil özeti için görünür ad (oturumdaki kimlik).
  final String creatorDisplayName;

  /// Üniversite / bölüm / sınıf / kampüs tek satırı (`CreatorProfile.studentProfileLine`).
  final String? studentProfilePreviewLine;
}
