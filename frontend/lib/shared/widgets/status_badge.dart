import 'package:flutter/material.dart';

import 'package:tur_izim/shared/widgets/tur_izim_status_pill.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (color == null) {
      return TurIzimStatusPill(label: label, tone: TurIzimStatusTone.info);
    }

    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: scheme.onSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
