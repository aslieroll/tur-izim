/// Uygulama genelinde kullanılan sabitler.
abstract final class AppConstants {
  AppConstants._();

  static const String appName = 'Tur İzim';

  /// Tasarım sistemi: minimum dokunma hedefi (yaklaşık 48dp).
  static const double minTouchTarget = 48;

  /// Yerleşim ızgarası (8px katları).
  static const double grid = 8;

  /// Stitch / Premium Travel Pass — sayfa yatay boşluğu (DESIGN.md margin-page).
  static const double pageHorizontalMargin = 24;

  /// İlgisiz bloklar arası dikey boşluk (section-gap ile uyumlu, mobilde biraz sıkı).
  static const double sectionGapLarge = 32;

  /// Kart içi ferah padding (internal breathing room).
  static const double cardInternalPadding = 20;
}
