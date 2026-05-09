import 'passport_type.dart';
import 'visa_eligibility_status.dart';

/// Kalıcı üretici profili — Uygunluk endeksinde kullanılacak boole işaretleri.
class CreatorProfile {
  const CreatorProfile({
    required this.id,
    required this.displayName,
    required this.instagramUrl,
    required this.tiktokUrl,
    required this.youtubeUrl,
    required this.portfolioUrl,
    required this.hasPublicInstagram,
    required this.hasPublicTiktok,
    required this.canCreateVerticalVideo,
    required this.canShootPhotos,
    required this.canDeliverRawFiles,
    required this.hasBasicEditingSkill,
    required this.hasTravelVlogExperience,
    required this.canRecord1080pVideo,
    required this.passportType,
    required this.hasValidPassport,
    required this.visaEligibility,
  });

  final String id;
  final String displayName;
  final String? instagramUrl;
  final String? tiktokUrl;
  final String? youtubeUrl;
  final String? portfolioUrl;

  final bool hasPublicInstagram;
  final bool hasPublicTiktok;

  final bool canCreateVerticalVideo;
  final bool canShootPhotos;
  final bool canDeliverRawFiles;

  final bool hasBasicEditingSkill;
  final bool hasTravelVlogExperience;
  final bool canRecord1080pVideo;

  /// Beyan edilen pasaport türü (gerçek doğrulama yok).
  final PassportType passportType;

  /// Geçerli pasaport olduğu beyanı (MVP).
  final bool hasValidPassport;

  /// İlgili yurt dışı turlar için vize uygunluğu beyanı (MVP).
  final VisaEligibilityStatus visaEligibility;
}
