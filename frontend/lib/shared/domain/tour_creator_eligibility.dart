import 'package:tur_izim/shared/models/creator_profile.dart';
import 'package:tur_izim/shared/models/passport_type.dart';
import 'package:tur_izim/shared/models/tour_scope.dart';
import 'package:tur_izim/shared/models/tour_summary.dart';
import 'package:tur_izim/shared/models/visa_eligibility_status.dart';

/// Yurt dışı ilanları için basit pasaport/vize uygunluk kuralı (widget dışında).
abstract final class TourCreatorEligibility {
  TourCreatorEligibility._();

  static bool isEligible({
    required CreatorProfile profile,
    required TourSummary tour,
  }) {
    if (tour.tourScope == TourScope.domestic) {
      return true;
    }
    if (tour.requiresPassport) {
      if (!profile.hasValidPassport) {
        return false;
      }
      if (profile.passportType.strengthRank <
          tour.minimumPassportType.strengthRank) {
        return false;
      }
    }
    if (tour.requiresVisa) {
      if (profile.visaEligibility != VisaEligibilityStatus.hasRequiredVisa) {
        return false;
      }
    }
    return true;
  }
}
