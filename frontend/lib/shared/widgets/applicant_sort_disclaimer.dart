import 'package:flutter/material.dart';

import '../theme/tur_izim_design_tokens.dart';

class ApplicantSortDisclaimer extends StatelessWidget {
  const ApplicantSortDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: TurIzimPalette.softLavender.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(TurIzimDesignTokens.radiusMedium),
        border: Border.all(
          color: TurIzimPalette.deepNavy.withValues(alpha: 0.06),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.gavel_outlined, color: TurIzimPalette.deepNavy, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Aday listesi sıralaması görsel olarak Aday Uygunluk Endeksi ile '
                'desteklenebilir; otomatik atama ya da sistem önerili seçim yoktur. '
                'Üniversite öğrencisi içerik üreticisi seçiminiz tamamen '
                'acentenize aittir.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: TurIzimPalette.slateText.withValues(alpha: 0.92),
                      height: 1.45,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
