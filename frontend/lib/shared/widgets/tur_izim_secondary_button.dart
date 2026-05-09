import 'package:flutter/material.dart';

import 'package:tur_izim/shared/theme/tur_izim_design_tokens.dart';

/// İkincil CTA — görünür ama birincil aksiyonla rekabet etmez.
class TurIzimSecondaryButton extends StatelessWidget {
  const TurIzimSecondaryButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final button = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.72),
        foregroundColor: TurIzimPalette.deepNavy,
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.85),
        ),
      ),
      child: _ButtonContent(label: label, icon: icon),
    );

    if (!fullWidth) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    if (icon == null) {
      return Text(label, textAlign: TextAlign.center);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Flexible(child: Text(label, textAlign: TextAlign.center)),
      ],
    );
  }
}
