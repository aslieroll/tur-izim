import '../models/creator_profile.dart';

/// Kısa özet satırları (mock profil alanlarından); takipçi sayısı vb. yok.
List<String> creatorProfileMockPreviewBullets(CreatorProfile p) {
  final lines = <String>[];
  if (p.hasPublicInstagram) lines.add('Instagram (kamuya açık)');
  if (p.hasPublicTiktok) lines.add('TikTok (kamuya açık)');
  if (p.canCreateVerticalVideo) lines.add('Dikey video içeriği');
  if (p.canShootPhotos) lines.add('Fotoğraf çekimi');
  if (p.hasTravelVlogExperience) {
    lines.add('Seyahat vlog deneyimi');
  }
  lines.add(
    p.canDeliverRawFiles
        ? 'Ham dosya teslimi: uygun'
        : 'Ham dosya teslimi: sınırlı',
  );
  return lines.take(5).toList();
}
