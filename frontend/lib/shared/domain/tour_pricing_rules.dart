import 'package:tur_izim/core/errors/app_exception.dart';
import 'package:tur_izim/shared/models/tour_status.dart';
import 'package:tur_izim/shared/models/tour_summary.dart';

/// Yayımlanmış ilan fiyat kuralları (mock/API ile uyumlu).
abstract final class TourPricingRules {
  TourPricingRules._();

  /// Yayındaki ilanlar için: normal fiyat ve beklenen depozito pozitif;
  /// depozito normal fiyatı aşamaz.
  static void validatePublishedTour(TourSummary tour) {
    if (tour.status != TourStatus.published) {
      return;
    }
    if (tour.normalSalesPrice <= 0) {
      throw const AppException(
        'Yayımlanmış tur için normal satış fiyatı sıfırdan büyük olmalıdır.',
      );
    }
    if (tour.expectedDepositAmount <= 0) {
      throw const AppException(
        'Yayımlanmış tur için beklenen depozito sıfırdan büyük olmalıdır.',
      );
    }
    if (tour.expectedDepositAmount > tour.normalSalesPrice) {
      throw const AppException(
        'Beklenen depozito, normal satış fiyatını aşamaz.',
      );
    }
  }
}
