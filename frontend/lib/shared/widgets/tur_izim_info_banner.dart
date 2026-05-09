import 'package:flutter/material.dart';

import 'package:tur_izim/shared/theme/tur_izim_design_tokens.dart';
import 'package:tur_izim/shared/widgets/tur_izim_status_pill.dart';

/// Bilgi/uyarı bandı. İş kuralı değil, yalnızca tutarlı görsel taşıyıcıdır.
class TurIzimInfoBanner extends StatelessWidget {
  const TurIzimInfoBanner({
    required this.message,
    super.key,
    this.title,
    this.tone = TurIzimStatusTone.info,
    this.icon,
  });

  final String? title;
  final String message;
  final TurIzimStatusTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _colorsFor(context, tone);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(TurIzimDesignTokens.radiusMedium),
        border: Border.all(color: colors.foreground.withValues(alpha: 0.10)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon ?? Icons.info_outline_rounded,
              color: colors.foreground,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null && title!.trim().isNotEmpty) ...[
                    Text(
                      title!,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colors.foreground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _BannerColors _colorsFor(BuildContext context, TurIzimStatusTone tone) {
    final scheme = Theme.of(context).colorScheme;
    final semantic = context.turIzimSemanticColors;
    return switch (tone) {
      TurIzimStatusTone.success => _BannerColors(
        background: semantic.success.withValues(alpha: 0.10),
        foreground: const Color(0xFF166534),
      ),
      TurIzimStatusTone.warning => _BannerColors(
        background: semantic.warning.withValues(alpha: 0.12),
        foreground: const Color(0xFF92400E),
      ),
      TurIzimStatusTone.danger => _BannerColors(
        background: scheme.errorContainer.withValues(alpha: 0.65),
        foreground: scheme.error,
      ),
      TurIzimStatusTone.accent => _BannerColors(
        background: TurIzimPalette.softCoral.withValues(alpha: 0.10),
        foreground: TurIzimPalette.deepNavy,
      ),
      TurIzimStatusTone.neutral => _BannerColors(
        background: scheme.surfaceContainerLow,
        foreground: scheme.onSurfaceVariant,
      ),
      TurIzimStatusTone.info => _BannerColors(
        background: TurIzimPalette.softSkyBlue.withValues(alpha: 0.62),
        foreground: TurIzimPalette.royalIndigo,
      ),
    };
  }
}

class _BannerColors {
  const _BannerColors({required this.background, required this.foreground});

  final Color background;
  final Color foreground;
}
