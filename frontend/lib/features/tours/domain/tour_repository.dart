import 'package:tur_izim/shared/models/tour_detail.dart';
import 'package:tur_izim/shared/models/tour_summary.dart';

abstract class TourRepository {
  Future<List<TourSummary>> fetchPublishedTours();

  /// Kota ve yayın koşullarına ek olarak pasaport/vize uygunluğu süzülür.
  Future<List<TourSummary>> fetchPublishedToursForCreator(String creatorId);

  Future<bool> isCreatorEligibleForTour({
    required String creatorId,
    required String tourId,
  });

  Future<TourDetail?> fetchTourDetail(String id);

  Future<List<TourSummary>> fetchAgencyTours(String agencyId);

  Future<bool> hasCreatorApplied({
    required String tourId,
    required String creatorId,
  });
}
