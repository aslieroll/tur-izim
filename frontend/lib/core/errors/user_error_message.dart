import 'package:tur_izim/core/api/api_exception.dart';
import 'package:tur_izim/core/errors/app_exception.dart';

/// Snackbar / gövde için güvenli metin (stack trace yok).
String userFacingErrorMessage(Object? error) {
  if (error is ApiException) return error.userMessage;
  if (error is AppException) return error.message;
  return error?.toString().contains('Exception') == false &&
          error?.toString().isNotEmpty == true
      ? error.toString()
      : 'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.';
}
