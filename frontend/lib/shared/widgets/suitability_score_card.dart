import 'package:flutter/material.dart';

import '../mappers/suitability_tier_mapper.dart';
import '../models/suitability_scores.dart';
import '../theme/tur_izim_design_tokens.dart';
import 'tur_izim_surface_card.dart';
import 'tur_izim_status_pill.dart';

/// AUE + bileşenler — skorları API/mock verir; bileşik hesap yapılmaz.
class SuitabilityScoreCard extends StatelessWidget {
  const SuitabilityScoreCard({super.key, required this.scores});

  final SuitabilityScores scores;

  @override
  Widget build(BuildContext context) {
    final tier = suitabilityTierLabelTurkish(scores.aue);
    final theme = Theme.of(context);

    return TurIzimSurfaceCard(
      padding: const EdgeInsets.all(TurIzimDesignTokens.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Aday Uygunluk Endeksi',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: TurIzimPalette.deepNavy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TurIzimStatusPill(
                tone: TurIzimStatusTone.info,
                label: tier,
                icon: Icons.analytics_outlined,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${scores.aue.round()}/100',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: TurIzimPalette.royalIndigo,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          _row(
            context,
            'Teknik kriter uyumu',
            '${scores.technicalFit.toStringAsFixed(1)}%',
          ),
          _row(
            context,
            'Yayın platform uyumu',
            '${scores.publicationFit.toStringAsFixed(1)}%',
          ),
          _row(
            context,
            'Karşılanan teknik gereksinim sayısı',
            '${scores.matchedRequirementCount} / '
                '${scores.totalRequirementCount}',
          ),
          if (scores.missingRequirementsText.trim().isNotEmpty) ...[
            const Divider(height: 28),
            Text(
              'Eksik veya uyarı veren kriterler',
              style: theme.textTheme.titleSmall?.copyWith(
                color: TurIzimPalette.deepNavy,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              scores.missingRequirementsText,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
          ],
          const SizedBox(height: 14),
          Text(
            'Bu skor karar destek amaçlıdır. Nihai seçim acenteye aittir.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: TurIzimPalette.mutedText,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              k,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: TurIzimPalette.slateText.withValues(alpha: 0.88),
                  ),
            ),
          ),
          Text(
            v,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: TurIzimPalette.deepNavy,
                ),
          ),
        ],
      ),
    );
  }
}
