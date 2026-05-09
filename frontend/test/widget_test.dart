import 'package:flutter_test/flutter_test.dart';

import 'package:tur_izim/app/app.dart';

void main() {
  testWidgets('Karşılama ekranı temel içerik', (WidgetTester tester) async {
    await tester.pumpWidget(const TurIzimApp());

    expect(find.text('Tur İzim'), findsOneWidget);
    expect(find.text('İçerik Üreticisi Olarak Devam Et'), findsOneWidget);
    expect(find.text('Acente Olarak Devam Et'), findsOneWidget);
    expect(find.text('Admin Girişi'), findsOneWidget);
    expect(find.textContaining('sosyal akış'), findsOneWidget);
  });
}
