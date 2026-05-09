import 'package:flutter/material.dart';

import 'package:tur_izim/shared/theme/tur_izim_design_tokens.dart';

enum TurIzimStatusTone { neutral, info, success, warning, danger, accent }

/// Premium Travel Pass durum rozeti.
///
/// Yalnızca görsel bir bileşendir; durum makinesi veya iş kuralı içermez.
class TurIzimStatusPill extends StatelessWidget {
  const TurIzimStatusPill({
    required this.label,
    super.key,
    this.tone = TurIzimStatusTone.neutral,
    this.icon,
  });

  final String label;
  final TurIzimStatusTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _colorsFor(context, tone);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(TurIzimDesignTokens.radiusPill),
        border: Border.all(color: colors.foreground.withValues(alpha: 0.10)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: colors.foreground),
              const SizedBox(width: 5),
            ],
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.foreground,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _PillColors _colorsFor(BuildContext context, TurIzimStatusTone tone) {
    final scheme = Theme.of(context).colorScheme;
    final semantic = context.turIzimSemanticColors;
    return switch (tone) {
      TurIzimStatusTone.info => _PillColors(
        background: TurIzimPalette.softSkyBlue,
        foreground: TurIzimPalette.deepNavy,
      ),
      TurIzimStatusTone.success => _PillColors(
        background: semantic.success.withValues(alpha: 0.12),
        foreground: const Color(0xFF166534),
      ),
      TurIzimStatusTone.warning => _PillColors(
        background: semantic.warning.withValues(alpha: 0.14),
        foreground: const Color(0xFF92400E),
      ),
      TurIzimStatusTone.danger => _PillColors(
        background: scheme.errorContainer,
        foreground: scheme.onErrorContainer,
      ),
      TurIzimStatusTone.accent => _PillColors(
        background: TurIzimPalette.softCoral.withValues(alpha: 0.14),
        foreground: TurIzimPalette.deepNavy,
      ),
      TurIzimStatusTone.neutral => _PillColors(
        background: scheme.surfaceContainerHigh,
        foreground: scheme.onSurfaceVariant,
      ),
    };
  }
}

class _PillColors {
  const _PillColors({required this.background, required this.foreground});

  final Color background;
  final Color foreground;
}
