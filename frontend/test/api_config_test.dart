import 'package:flutter_test/flutter_test.dart';
import 'package:tur_izim/core/api/api_config.dart';

void main() {
  test('ApiConfig default base URL', () {
    expect(ApiConfig.baseUrl, isNotEmpty);
    expect(ApiConfig.uri('/api/health').toString(), contains('8080'));
    expect(ApiConfig.uri('/api/health').path, '/api/health');
  });
}
