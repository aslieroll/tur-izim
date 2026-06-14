/// Sunucu veya ağ hatası — UI ham stack trace göstermez, [userMessage] kullanır.
final class ApiException implements Exception {
  ApiException({
    required this.userMessage,
    this.statusCode,
    this.code,
    this.body,
    this.cause,
  });

  /// HTTP cevabı (yoksa ağ hatası).
  final int? statusCode;

  /// Sunucu `ApiErrorResponse.code` veya `VALIDATION` vb.
  final String? code;

  final String? body;

  final Object? cause;

  /// Ekranda gösterilecek kısa Türkçe metin.
  final String userMessage;

  bool get isBusinessRule => statusCode != null && statusCode! >= 400 && statusCode! < 500;

  /// Geri kazanılabilir: backend kapalı, DNS, zaman aşımı vb.
  bool get isConnectivityOrServerGap =>
      statusCode == null ||
      statusCode == 502 ||
      statusCode == 503 ||
      statusCode == 504;

  bool get isUnauthorized => statusCode == 401;

  bool get isAuthRequired => isUnauthorized || statusCode == 403;

  @override
  String toString() => 'ApiException($statusCode, $code: $userMessage)';
}
