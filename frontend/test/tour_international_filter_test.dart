import 'package:flutter_test/flutter_test.dart';

import 'package:tur_izim/core/constants/mock_actor_ids.dart';
import 'package:tur_izim/core/bootstrap/tur_izim_mock_bootstrap.dart';
import 'package:tur_izim/features/tours/domain/tour_repository.dart';

void main() {
  group('Yayımlı tur seed kapsamı (mock)', () {
    late TourRepository repo;

    setUp(() {
      repo = TurIzimMockBootstrap().tours;
    });

    test('Ayşe iki yayımlanmış tur görür', () async {
      final list = await repo.fetchPublishedToursForCreator(
        MockActorIds.creatorAlice,
      );
      expect(list.length, 2);
    });

    test('Mehmet de aynı iki yayımlı turu görür', () async {
      final list = await repo.fetchPublishedToursForCreator(
        MockActorIds.creatorBob,
      );
      expect(list.length, 2);
    });
  });
}
