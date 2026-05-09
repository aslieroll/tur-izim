import '../models/creator_profile.dart';
import '../models/student_verification_status.dart';

/// Kısa özet satırları (mock profil alanlarından).
/// Öğrenci profil satırı AUE bileşeni değildir — yalnızca görünürlük bilgisidir.
List<String> creatorProfileMockPreviewBullets(CreatorProfile p) {
  final lines = <String>[];

  // Student profile line (shown first if available — AUE dışı)
  final studentLine = p.studentProfileLine;
  if (studentLine != null) {
    final verifiedSuffix = p.studentVerificationStatus ==
            StudentVerificationStatus.verified
        ? ' ✓'
        : '';
    lines.add('Öğrenci: $studentLine$verifiedSuffix');
  }

  if (p.hasPublicInstagram) lines.add('Instagram (kamuya açık)');
  if (p.hasPublicTiktok) lines.add('TikTok (kamuya açık)');
  if (p.canCreateVerticalVideo) lines.add('Dikey video içeriği');
  if (p.canShootPhotos) lines.add('Fotoğraf çekimi');
  if (p.hasTravelVlogExperience) lines.add('Seyahat vlog deneyimi');
  lines.add(
    p.canDeliverRawFiles
        ? 'Ham dosya teslimi: uygun'
        : 'Ham dosya teslimi: sınırlı',
  );
  return lines.take(6).toList();
}

/// Öğrenci doğrulama durumu etiketi (Türkçe).
String studentVerificationStatusLabel(StudentVerificationStatus s) =>
    switch (s) {
      StudentVerificationStatus.unverified => 'Öğrenci profili doğrulanmadı',
      StudentVerificationStatus.pendingReview => 'Öğrenci profili incelemede',
      StudentVerificationStatus.verified => 'Öğrenci profili onaylı',
      StudentVerificationStatus.rejected => 'Öğrenci profili reddedildi',
    };
