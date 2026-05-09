import 'package:flutter/material.dart';

import 'package:tur_izim/shared/models/tour_scope.dart';
import 'package:tur_izim/shared/models/tour_summary.dart';
import 'package:tur_izim/shared/presentation/travel_eligibility_labels_turkish.dart';

/// Acente kartları için kapsam + yurt dışı şart özeti.
class TourTravelScopeSummaryLines extends StatelessWidget {
  const TourTravelScopeSummaryLines({
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
    final color = theme.colorScheme.onSurfaceVariant;
    final lines = <Widget>[
      Text(
        'Tur kapsamı: ${tourScopeLabelTurkish(tour.tourScope)}',
        style: style?.copyWith(color: color),
      ),
    ];
    if (tour.tourScope == TourScope.international) {
      final passportLine = tour.requiresPassport
          ? 'Pasaport: min. '
                '${passportTypeLabelTurkish(tour.minimumPassportType)}'
          : 'Pasaport şartı beyanı yok';
      final visaLine = tour.requiresVisa
          ? (tour.visaRequirementText != null &&
                    tour.visaRequirementText!.trim().isNotEmpty
                ? 'Vize: ${tour.visaRequirementText}'
                : 'Vize şartı: acente metni tanımlı değil')
          : 'Vize şartı beyanı yok';
      lines.add(
        Padding(
          padding: EdgeInsets.only(top: dense ? 2 : 4),
          child: Text(passportLine, style: style?.copyWith(color: color)),
        ),
      );
      lines.add(
        Padding(
          padding: EdgeInsets.only(top: dense ? 2 : 4),
          child: Text(visaLine, style: style?.copyWith(color: color)),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines,
    );
  }
}
