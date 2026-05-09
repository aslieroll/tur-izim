import 'package:flutter/material.dart';

import 'package:tur_izim/shared/models/tour_summary.dart';
import 'package:tur_izim/shared/presentation/turkish_lira_format.dart';

/// Bilgilendirme satırları (iş kuralı mağazada).
class TourPricingInfoLines extends StatelessWidget {
  const TourPricingInfoLines({
    required this.tour,
    super.key,
    this.dense = false,
  });

  final TourSummary tour;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = dense
        ? theme.textTheme.bodySmall
        : theme.textTheme.bodyMedium;
    final variantColor = theme.colorScheme.onSurfaceVariant;
    final code = tour.currency;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Normal satış fiyatı: '
          '${formatTurkishLiraAmount(tour.normalSalesPrice, currencyCode: code)}',
          style: style?.copyWith(color: variantColor),
        ),
        SizedBox(height: dense ? 2 : 4),
        Text(
          'Beklenen depozito: '
          '${formatTurkishLiraAmount(tour.expectedDepositAmount, currencyCode: code)}',
          style: style?.copyWith(color: variantColor),
        ),
      ],
    );
  }
}
