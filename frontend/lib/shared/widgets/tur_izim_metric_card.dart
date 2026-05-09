import 'package:flutter/material.dart';

import 'package:tur_izim/shared/theme/tur_izim_design_tokens.dart';
import 'package:tur_izim/shared/widgets/tur_izim_surface_card.dart';

/// Dashboard ve özet ekranları için küçük metrik kartı.
class TurIzimMetricCard extends StatelessWidget {
  const TurIzimMetricCard({
    required this.label,
    required this.value,
    super.key,
    this.icon,
    this.supportingText,
    this.accentColor,
  });

  final String label;
  final String value;
  final IconData? icon;
  final String? supportingText;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = accentColor ?? TurIzimPalette.royalIndigo;

    return TurIzimSurfaceCard(
      padding: const EdgeInsets.all(TurIzimDesignTokens.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(
                      TurIzimDesignTokens.radiusMedium,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(icon, color: accent, size: 20),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.55,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (supportingText != null && supportingText!.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              supportingText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
