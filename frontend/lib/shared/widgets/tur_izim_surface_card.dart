import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

/// Yuvarlatılmış yüzey kartı; tema `CardTheme` + opsiyonel dokunma.
class TurIzimSurfaceCard extends StatelessWidget {
  const TurIzimSurfaceCard({
    required this.child,
    super.key,
    this.onTap,
    this.padding = const EdgeInsets.all(AppConstants.cardInternalPadding),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? Padding(padding: padding, child: child)
          : InkWell(
              onTap: onTap,
              child: Padding(padding: padding, child: child),
            ),
    );
    return card;
  }
}
