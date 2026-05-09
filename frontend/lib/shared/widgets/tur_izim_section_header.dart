import 'package:flutter/material.dart';

/// Bölüm başlığı + isteğe bağlı alt başlık (Premium Travel Pass hiyerarşisi).
class TurIzimSectionHeader extends StatelessWidget {
  const TurIzimSectionHeader({
    required this.title,
    super.key,
    this.subtitle,
    this.overline,
    this.action,
  });

  final String title;
  final String? subtitle;
  final String? overline;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (overline != null && overline!.trim().isNotEmpty) ...[
          Text(
            overline!.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (action != null) ...[const SizedBox(width: 12), action!],
          ],
        ),
        if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}
