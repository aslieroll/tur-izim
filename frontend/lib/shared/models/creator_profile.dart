import 'passport_type.dart';
import 'student_verification_status.dart';
import 'visa_eligibility_status.dart';

/// Kalıcı üretici profili — Uygunluk endeksinde kullanılacak boole işaretleri
/// ve opsiyonel üniversite öğrencisi profil bilgileri.
///
/// Öğrenci profil alanları (universityName, departmentName, classYear,
/// campusCity, studentVerificationStatus) AUE hesabına dahil edilmez.
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
    // Student profile — optional, NOT part of AUE
    this.universityName,
    this.departmentName,
    this.classYear,
    this.campusCity,
    this.studentVerificationStatus = StudentVerificationStatus.unverified,
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

  // ── Üniversite öğrencisi profil bilgileri (AUE dışı) ───────────────────

  /// Üniversite / okul adı (opsiyonel beyan).
  final String? universityName;

  /// Bölüm adı (opsiyonel beyan).
  final String? departmentName;

  /// Sınıf (1–4+); opsiyonel.
  final int? classYear;

  /// Kampüs şehri (opsiyonel beyan).
  final String? campusCity;

  /// MVP'de otomatik doğrulama yoktur; genellikle UNVERIFIED kalır.
  final StudentVerificationStatus studentVerificationStatus;

  /// "Çukurova Üniversitesi · Yazılım Mühendisliği · 3. sınıf · Adana"
  /// sırasında tek satırlık öğrenci özeti (AUE dışıdır).
  String? get studentProfileLine {
    final parts = <String>[];
    if (universityName != null) parts.add(universityName!);
    if (departmentName != null) parts.add(departmentName!);
    if (classYear != null) parts.add('$classYear. sınıf');
    if (campusCity != null) parts.add(campusCity!);
    if (parts.isEmpty) return null;
    return parts.join(' · ');
  }
}
