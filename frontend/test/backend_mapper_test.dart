import 'package:flutter_test/flutter_test.dart';
import 'package:tur_izim/core/api/backend_dto_mappers.dart';
import 'package:tur_izim/shared/models/tour_scope.dart';
void main() {
  test('tourSummaryFromBackendJson maps prices and scope', () {
    final m = <String, dynamic>{
      'id': '11111111-1111-1111-1111-111111111111',
      'agencyId': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      'agencyName': 'Demo Acente',
      'title': 'Test turu',
      'description': 'D',
      'departureCity': 'İstanbul',
      'destination': 'Kapadokya',
      'startDate': '2026-06-01',
      'endDate': '2026-06-03',
      'normalSalePrice': 10000.5,
      'expectedDepositAmount': 500,
      'tourType': 'DOMESTIC',
      'status': 'PUBLISHED',
      'passportVisaSummary': 'Pasaport/vize şartı yok (yurt içi veya beyan yok).',
      'availableCreatorSeats': 3,
    };
    final t = tourSummaryFromBackendJson(m);
    expect(t.id, m['id']);
    expect(t.tourScope, TourScope.domestic);
    expect(t.normalSalesPrice, 10000.5);
    expect(t.expectedDepositAmount, 500.0);
    expect(t.creatorQuota, 3);
  });
}
