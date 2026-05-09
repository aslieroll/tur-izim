import 'package:flutter/material.dart';

import 'package:tur_izim/shared/models/tour_detail.dart';
import 'package:tur_izim/shared/models/tour_scope.dart';
import 'package:tur_izim/shared/presentation/travel_eligibility_labels_turkish.dart';

/// Yurt dışı ilanlarda pasaport/vize şartları (bilgilendirme; doğrulama yok).
class InternationalMandatoryRequirementsCard extends StatelessWidget {
  const InternationalMandatoryRequirementsCard({required this.tour, super.key});

  final TourDetail tour;

  @override
  Widget build(BuildContext context) {
    if (tour.tourScope != TourScope.international) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Zorunlu gereklilikler (pasaport / vize)',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 10),
            Text(
              'Tur İzim resmi pasaport veya vize doğrulaması yapmaz; '
              'aşağıdaki maddeler acentenin beyanıdır.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            if (tour.requiresPassport) ...[
              Text(
                'Pasaport: geçerli pasaport beyanı zorunlu; minimum tür: '
                '${passportTypeLabelTurkish(tour.minimumPassportType)}.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
            ],
            if (tour.requiresVisa)
              Text(
                'Vize / giriş: ${tour.visaRequirementText ?? 'Acente şartı '
                        'tanımlanmadı.'}',
                style: theme.textTheme.bodyMedium,
              ),
          ],
        ),
      ),
    );
  }
}
