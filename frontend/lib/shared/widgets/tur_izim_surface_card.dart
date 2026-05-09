import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../theme/tur_izim_design_tokens.dart';

/// Yuvarlatılmış yüzey kartı; tema `CardTheme` + opsiyonel dokunma.
class TurIzimSurfaceCard extends StatelessWidget {
  const TurIzimSurfaceCard({
    required this.child,
    super.key,
    this.onTap,
    this.padding = const EdgeInsets.all(AppConstants.cardInternalPadding),
    this.backgroundColor,
    this.borderColor,
    this.usePremiumShadow = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool usePremiumShadow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Padding(padding: padding, child: child);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(TurIzimDesignTokens.radiusLarge),
        border: Border.all(
          color:
              borderColor ??
              theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
        boxShadow: usePremiumShadow
            ? TurIzimDesignTokens.premiumShadow()
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(TurIzimDesignTokens.radiusLarge),
        child: Material(
          color: Colors.transparent,
          child: onTap == null
              ? content
              : InkWell(onTap: onTap, child: content),
        ),
      ),
    );
  }
}
