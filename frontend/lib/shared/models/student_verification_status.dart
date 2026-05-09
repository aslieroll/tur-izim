/// Öğrenci profil doğrulama durumu.
///
/// AUE (Aday Uygunluk Endeksi) hesabına dahil edilmez.
/// MVP'de otomatik belge doğrulama yoktur; genellikle [unverified] kalır.
enum StudentVerificationStatus {
  unverified,
  pendingReview,
  verified,
  rejected,
}
