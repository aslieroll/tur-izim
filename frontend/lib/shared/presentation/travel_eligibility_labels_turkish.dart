import 'package:tur_izim/shared/models/passport_type.dart';
import 'package:tur_izim/shared/models/tour_scope.dart';
import 'package:tur_izim/shared/models/visa_eligibility_status.dart';

String tourScopeLabelTurkish(TourScope scope) => switch (scope) {
  TourScope.domestic => 'Yurt içi',
  TourScope.international => 'Yurt dışı',
};

String passportTypeLabelTurkish(PassportType t) => switch (t) {
  PassportType.none => 'Yok / beyan edilmedi',
  PassportType.bordo => 'Bordo (genel)',
  PassportType.yesil => 'Yeşil',
  PassportType.gri => 'Gri',
  PassportType.siyah => 'Siyah',
};

String visaEligibilityLabelTurkish(VisaEligibilityStatus v) => switch (v) {
  VisaEligibilityStatus.none => 'Vize beyanı yok / uygun değil',
  VisaEligibilityStatus.hasRequiredVisa => 'Gerekli vizeye sahibim (beyan)',
};
