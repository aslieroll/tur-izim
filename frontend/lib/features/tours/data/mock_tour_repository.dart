import 'package:tur_izim/core/mock/mock_tur_izim_store.dart';
import 'package:tur_izim/shared/models/tour_detail.dart';
import 'package:tur_izim/shared/models/tour_summary.dart';

import '../domain/tour_repository.dart';

final class MockTourRepository implements TourRepository {
  MockTourRepository(this._store);

  final MockTurIzimStore _store;

  @override
  Future<List<TourSummary>> fetchAgencyTours(String agencyId) async {
    await Future<void>.delayed(const Duration(milliseconds: 35));
    return _store.agencyTours(agencyId);
  }

  @override
  Future<TourDetail?> fetchTourDetail(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 35));
    try {
      return _store.snapshotTourDetail(id);
    } on Object {
      return null;
    }
  }

  @override
  Future<List<TourSummary>> fetchPublishedTours() async {
    await Future<void>.delayed(const Duration(milliseconds: 35));
    return _store.publishedTours();
  }

  @override
  Future<List<TourSummary>> fetchPublishedToursForCreator(
    String creatorId,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 35));
    return _store.publishedToursForCreator(creatorId);
  }

  @override
  Future<bool> isCreatorEligibleForTour({
    required String creatorId,
    required String tourId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 25));
    try {
      final detail = _store.snapshotTourDetail(tourId);
      return _store.isCreatorEligibleForTour(
        creatorId: creatorId,
        tour: detail,
      );
    } on Object {
      return false;
    }
  }

  @override
  Future<bool> hasCreatorApplied({
    required String tourId,
    required String creatorId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 20));
    return _store.hasCreatorApplied(tourId: tourId, creatorId: creatorId);
  }
}
