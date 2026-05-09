import 'package:flutter_test/flutter_test.dart';

import 'package:tur_izim/shared/presentation/turkish_lira_format.dart';

void main() {
  group('formatTurkishLiraAmount', () {
    test('örnek MVP tutarları', () {
      expect(formatTurkishLiraAmount(3500), '3.500 TL');
      expect(formatTurkishLiraAmount(1500), '1.500 TL');
      expect(formatTurkishLiraAmount(11299), '11.299 TL');
    });
  });
}
