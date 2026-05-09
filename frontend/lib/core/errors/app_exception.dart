/// Uygulama içi hata sarmalayıcı (API mesajları ile genişletilebilir).
class AppException implements Exception {
  const AppException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'AppException: $message';
}
