/// Yerel geliştirme varsayılanı: Spring Boot `http://localhost:8080`.
///
/// Özel base URL için:
/// `flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080`
///
/// Ödeme linkleri artık frontend'e geçirilmez; backend env değişkenleri
/// (AGENCY_PRO_PAYMENT_LINK, AGENCY_GROWTH_PAYMENT_LINK) Railway'de ayarlanır.
abstract final class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  /// Örn. `/api/tours` → tam URI (base sonundaki `/` normalize edilir).
  static Uri uri(String path) {
    final base = baseUrl.replaceAll(RegExp(r'/+$'), '');
    final p = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$p');
  }
}
