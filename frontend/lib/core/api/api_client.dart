import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_exception.dart';

/// Tur İzim REST kökü ile konuşan ince HTTP sarmalayıcı (MVP; auth yok).
abstract interface class TurIzimApiClient {
  Future<void> close();

  Future<List<dynamic>> getJsonList(String path);

  Future<Map<String, dynamic>> getJson(String path);

  /// 404 → `null` (opsiyonel kaynak).
  Future<Map<String, dynamic>?> getJsonOrNull(String path);

  Future<Map<String, dynamic>> postJson(String path, Map<String, dynamic> body);
}

final class HttpTurIzimApiClient implements TurIzimApiClient {
  HttpTurIzimApiClient({
    http.Client? httpClient,
    Duration timeout = const Duration(seconds: 20),
  })  : _client = httpClient ?? http.Client(),
        _timeout = timeout;

  final http.Client _client;
  final Duration _timeout;

  @override
  Future<void> close() async {
    _client.close();
  }

  @override
  Future<List<dynamic>> getJsonList(String path) async {
    final decoded = await _decode(await _get(path));
    if (decoded is List<dynamic>) return decoded;
    throw ApiException(
      userMessage: 'Sunucu yanıtı beklenenden farklı (liste değil).',
      statusCode: 200,
    );
  }

  @override
  Future<Map<String, dynamic>> getJson(String path) async {
    final decoded = await _decode(await _get(path));
    if (decoded is Map<String, dynamic>) return decoded;
    throw ApiException(
      userMessage: 'Sunucu yanıtı beklenenden farklı.',
      statusCode: 200,
    );
  }

  @override
  Future<Map<String, dynamic>?> getJsonOrNull(String path) async {
    try {
      return await getJson(path);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> postJson(String path, Map<String, dynamic> body) async {
    final uri = ApiConfig.uri(path);
    try {
      final res = await _client
          .post(
            uri,
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return _decodeResponse(res);
    } on ApiException {
      rethrow;
    } on SocketException catch (e) {
      throw ApiException(
        userMessage: _backendUnreachableMessage(uri.host),
        cause: e,
      );
    } on http.ClientException catch (e) {
      throw ApiException(
        userMessage: _backendUnreachableMessage(uri.host),
        cause: e,
      );
    } catch (e) {
      throw ApiException(
        userMessage: 'İstek tamamlanamadı. Bağlantınızı kontrol edin.',
        cause: e,
      );
    }
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<http.Response> _get(String path) async {
    final uri = ApiConfig.uri(path);
    try {
      return await _client.get(uri, headers: _headers).timeout(_timeout);
    } on SocketException catch (e) {
      throw ApiException(
        userMessage: _backendUnreachableMessage(uri.host),
        cause: e,
      );
    } on http.ClientException catch (e) {
      throw ApiException(
        userMessage: _backendUnreachableMessage(uri.host),
        cause: e,
      );
    } catch (e) {
      throw ApiException(
        userMessage: 'İstek tamamlanamadı. Bağlantınızı kontrol edin.',
        cause: e,
      );
    }
  }

  Future<dynamic> _decode(http.Response res) async {
    return _decodeResponse(res);
  }

  dynamic _decodeResponse(http.Response res) {
    final code = res.statusCode;
    if (code >= 200 && code < 300) {
      if (res.body.isEmpty) {
        return <String, dynamic>{};
      }
      try {
        return jsonDecode(utf8.decode(res.bodyBytes));
      } catch (e) {
        throw ApiException(
          userMessage: 'Sunucu yanıtı çözülemedi.',
          statusCode: code,
          body: res.body,
          cause: e,
        );
      }
    }

    if (code == 404) {
      throw ApiException(
        userMessage: 'İstenen kaynak bulunamadı (404).',
        statusCode: code,
        body: res.body,
      );
    }

    try {
      final err = jsonDecode(utf8.decode(res.bodyBytes));
      if (err is Map<String, dynamic>) {
        final msg = err['message']?.toString();
        final c = err['code']?.toString();
        throw ApiException(
          userMessage: msg?.isNotEmpty == true
              ? msg!
              : 'İstek reddedildi ($code).',
          statusCode: code,
          code: c,
          body: res.body,
        );
      }
    } catch (_) {}

    throw ApiException(
      userMessage: code >= 500
          ? 'Sunucu geçici olarak kullanılamıyor ($code).'
          : 'İstek başarısız ($code). Yerel demo için backend\'in '
                'çalıştığını doğrulayın (ör. http://localhost:8080/api/health).',
      statusCode: code,
      body: res.body,
    );
  }

  static String _backendUnreachableMessage(String host) =>
      'Backend\'e bağlanılamıyor ($host). '
      'Spring Boot sunucusunun çalıştığından emin olun (genelde http://localhost:8080). ';
}
