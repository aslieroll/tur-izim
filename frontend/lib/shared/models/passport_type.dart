/// Üretici beyanı — gerçek pasaport doğrulaması yok (MVP).
enum PassportType { none, bordo, yesil, gri, siyah }

extension PassportTypeStrength on PassportType {
  /// Büyük = daha yüksek statülü pasaport (mock sıralama).
  int get strengthRank => switch (this) {
    PassportType.none => 0,
    PassportType.bordo => 1,
    PassportType.yesil => 2,
    PassportType.gri => 3,
    PassportType.siyah => 4,
  };
}
