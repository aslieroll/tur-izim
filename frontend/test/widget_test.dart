import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tur_izim/app/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Karşılama ekranı temel içerik', (WidgetTester tester) async {
    await tester.pumpWidget(const TurIzimApp());
    await tester.pumpAndSettle();

    expect(find.text('Tur İzim'), findsOneWidget);
    expect(find.text('İçerik Üreticisi Olarak Devam Et'), findsOneWidget);
    expect(find.text('Acente Olarak Devam Et'), findsOneWidget);
    expect(find.text('Admin Girişi'), findsOneWidget);
    expect(find.textContaining('sosyal akış'), findsOneWidget);
  });
}
