import 'package:flutter/material.dart';

import 'package:tur_izim/shared/models/tour_detail.dart';
import 'package:tur_izim/shared/models/tour_scope.dart';
import 'package:tur_izim/shared/presentation/travel_eligibility_labels_turkish.dart';
import 'package:tur_izim/shared/widgets/passport_visa_requirement_card.dart';

/// Yurt dışı ilanlarda pasaport/vize şartları (bilgilendirme; doğrulama yok).
class InternationalMandatoryRequirementsCard extends StatelessWidget {
  const InternationalMandatoryRequirementsCard({required this.tour, super.key});

  final TourDetail tour;

  @override
  Widget build(BuildContext context) {
    if (tour.tourScope != TourScope.international) {
      return const SizedBox.shrink();
    }

    return PassportVisaRequirementCard(
      requiresPassport: tour.requiresPassport,
      requiresVisa: tour.requiresVisa,
      minimumPassportTypeLabel: passportTypeLabelTurkish(
        tour.minimumPassportType,
      ),
      visaRequirementText: tour.visaRequirementText,
    );
  }
}
