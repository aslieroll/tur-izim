import 'package:flutter/material.dart';

import '../mappers/suitability_tier_mapper.dart';
import '../models/suitability_scores.dart';

/// AUE + bileşenler — skorları API/mock verir; bileşik hesap yapılmaz.
class SuitabilityScoreCard extends StatelessWidget {
  const SuitabilityScoreCard({super.key, required this.scores});

  final SuitabilityScores scores;

  @override
  Widget build(BuildContext context) {
    final tier = suitabilityTierLabelTurkish(scores.aue);

    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Aday Uygunluk Endeksi: ${scores.aue.round()}/100',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Chip(label: Text(tier), visualDensity: VisualDensity.compact),
              ],
            ),
            const SizedBox(height: 12),
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
              const Divider(height: 24),
              Text(
                'Eksik / uyarı özeti:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Text(scores.missingRequirementsText),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(child: Text(k)),
          Text(
            v,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
