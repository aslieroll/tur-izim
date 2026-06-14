import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:tur_izim/core/api/api_client.dart';

void main() {
  test('HttpTurIzimApiClient adds Authorization when token set', () async {
    final authHeaders = <String?>[];
    final mock = MockClient((request) async {
      authHeaders.add(request.headers['Authorization']);
      return http.Response(
        '[]',
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final api = HttpTurIzimApiClient(
      httpClient: mock,
      accessToken: () => 'secret-token',
    );
    addTearDown(api.close);
    await api.getJsonList('/api/tours');
    expect(authHeaders.single, 'Bearer secret-token');
  });

  test('HttpTurIzimApiClient skips Authorization when token null', () async {
    final keys = <List<String>>[];
    final mock = MockClient((request) async {
      keys.add(request.headers.keys.toList());
      return http.Response(
        '{"a":1}',
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final api = HttpTurIzimApiClient(
      httpClient: mock,
      accessToken: () => null,
    );
    addTearDown(api.close);
    await api.getJson('/api/health');
    expect(keys.single.contains('Authorization'), isFalse);
  });
}
