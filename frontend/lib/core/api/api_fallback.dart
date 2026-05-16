import 'package:tur_izim/core/api/api_exception.dart';

Future<T> runWithApiFallback<T>({
  required Future<T> Function() tryApi,
  required Future<T> Function() fallback,
}) async {
  try {
    return await tryApi();
  } on ApiException catch (e) {
    if (e.isConnectivityOrServerGap) {
      return await fallback();
    }
    rethrow;
  }
}
