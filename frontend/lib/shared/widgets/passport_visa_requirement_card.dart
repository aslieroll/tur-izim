import 'package:flutter/material.dart';

import 'package:tur_izim/shared/theme/tur_izim_design_tokens.dart';
import 'package:tur_izim/shared/widgets/tur_izim_info_banner.dart';
import 'package:tur_izim/shared/widgets/tur_izim_status_pill.dart';
import 'package:tur_izim/shared/widgets/tur_izim_surface_card.dart';

/// Yurt dışı turlar için pasaport/vize gereksinimlerini pasif olarak gösterir.
///
/// Bu bileşen uygunluk skorunu hesaplamaz ve başvuru kapısını tek başına
/// uygulamaz; yalnızca API/mock verisinden gelen gereksinimleri sunar.
class PassportVisaRequirementCard extends StatelessWidget {
  const PassportVisaRequirementCard({
    required this.requiresPassport,
    required this.requiresVisa,
    super.key,
    this.minimumPassportTypeLabel,
    this.visaRequirementText,
    this.isEligible,
  });

  final bool requiresPassport;
  final bool requiresVisa;
  final String? minimumPassportTypeLabel;
  final String? visaRequirementText;
  final bool? isEligible;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final requirementLines = <String>[
      if (requiresPassport)
        'Pasaport: ${minimumPassportTypeLabel ?? 'Geçerli pasaport beyanı'}',
      if (requiresVisa)
        'Vize / giriş: ${visaRequirementText ?? 'Acente beyanı'}',
      if (!requiresPassport && !requiresVisa)
        'Bu tur için pasaport/vize gereksinimi belirtilmemiştir.',
    ];

    return TurIzimSurfaceCard(
      padding: const EdgeInsets.all(TurIzimDesignTokens.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.badge_outlined, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Pasaport / Vize Gereksinimi',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (isEligible != null)
                TurIzimStatusPill(
                  label: isEligible! ? 'Uygun' : 'Uygun Değil',
                  tone: isEligible!
                      ? TurIzimStatusTone.success
                      : TurIzimStatusTone.warning,
                ),
            ],
          ),
          const SizedBox(height: 14),
          for (final line in requirementLines) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    line,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 6),
          const TurIzimInfoBanner(
            title: 'Skor bileşeni değildir',
            message:
                'Pasaport/vize uygunluğu yurt dışı turlar için ayrı başvuru kapısıdır; Aday Uygunluk Endeksi puanına eklenmez.',
            tone: TurIzimStatusTone.info,
            icon: Icons.info_outline_rounded,
          ),
        ],
      ),
    );
  }
}
