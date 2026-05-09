import 'package:flutter/material.dart';

import 'package:tur_izim/shared/models/tour_summary.dart';
import 'package:tur_izim/shared/theme/tur_izim_design_tokens.dart';

/// Safe local/mock visual header for tour cards and details.
///
/// Does NOT upload, fetch remote media, or create a gallery/feed.
/// If imageAssetPath is missing or null, renders a deterministic premium
/// gradient based on the tour's mock visualKey.
class TourVisualHeader extends StatelessWidget {
  const TourVisualHeader({
    required this.tour,
    super.key,
    this.height = 140,
    this.borderRadius,
    this.showLabel = true,
    this.showTitleOverlay = true,
  });

  final TourSummary tour;
  final double height;
  final BorderRadius? borderRadius;

  /// Show the destination label chip at bottom-left.
  final bool showLabel;

  /// Show the tour title and route at the bottom of the visual.
  final bool showTitleOverlay;

  @override
  Widget build(BuildContext context) {
    final spec = _TourVisualSpec.fromKey(tour.visualKey);
    final radius = borderRadius ?? BorderRadius.circular(TurIzimDesignTokens.radiusLarge);

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient background — always visible, no assets required
            if (tour.imageAssetPath == null)
              _GradientFallback(spec: spec)
            else
              Image.asset(
                tour.imageAssetPath!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _GradientFallback(spec: spec),
              ),

            // Decorative pattern overlay inside the gradient
            _PatternOverlay(spec: spec),

            // Dark gradient at the bottom so text is always legible
            if (showTitleOverlay || showLabel)
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.45, 1.0],
                    colors: [
                      Colors.transparent,
                      const Color(0xFF1E2A5A).withValues(alpha: 0.60),
                    ],
                  ),
                ),
              ),

            // Destination chip
            if (showLabel)
              Positioned(
                left: 14,
                bottom: showTitleOverlay ? 48 : 12,
                child: _DestinationChip(spec: spec),
              ),

            // Tour title and route at bottom
            if (showTitleOverlay)
              Positioned(
                left: 14,
                right: 14,
                bottom: 12,
                child: _TitleOverlay(tour: tour),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Gradient fallback ────────────────────────────────────────────────────────

class _GradientFallback extends StatelessWidget {
  const _GradientFallback({required this.spec});

  final _TourVisualSpec spec;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: spec.colors,
        ),
      ),
      child: const SizedBox.expand(),
    );
  }
}

// ── Decorative orbs/pattern on the gradient ──────────────────────────────────

class _PatternOverlay extends StatelessWidget {
  const _PatternOverlay({required this.spec});

  final _TourVisualSpec spec;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          right: -28,
          top: -32,
          child: _Orb(size: 120, color: Colors.white.withValues(alpha: 0.18)),
        ),
        Positioned(
          left: -22,
          bottom: -26,
          child: _Orb(size: 96, color: Colors.white.withValues(alpha: 0.13)),
        ),
        Positioned(
          right: 20,
          top: 14,
          child: Icon(
            spec.icon,
            size: 52,
            color: Colors.white.withValues(alpha: 0.24),
          ),
        ),
      ],
    );
  }
}

// ── Destination label chip ───────────────────────────────────────────────────

class _DestinationChip extends StatelessWidget {
  const _DestinationChip({required this.spec});

  final _TourVisualSpec spec;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(TurIzimDesignTokens.radiusPill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(spec.icon, size: 14, color: TurIzimPalette.royalIndigo),
            const SizedBox(width: 6),
            Text(
              spec.label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: TurIzimPalette.deepNavy,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tour title + route overlay at bottom ─────────────────────────────────────

class _TitleOverlay extends StatelessWidget {
  const _TitleOverlay({required this.tour});

  final TourSummary tour;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          tour.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            height: 1.2,
            shadows: [
              Shadow(
                color: const Color(0xFF1E2A5A).withValues(alpha: 0.40),
                blurRadius: 6,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Orb helper ───────────────────────────────────────────────────────────────

class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

// ── Visual spec lookup ───────────────────────────────────────────────────────

/// Maps mock visualKey → saturated gradient colors and a destination icon/label.
///
/// Colors are deliberately more saturated than the "soft" palette tokens so they
/// read clearly as a visual header without requiring real image assets.
class _TourVisualSpec {
  const _TourVisualSpec({
    required this.label,
    required this.icon,
    required this.colors,
  });

  final String label;
  final IconData icon;
  final List<Color> colors;

  static _TourVisualSpec fromKey(String? key) {
    return switch (key) {
      'cappadocia' => const _TourVisualSpec(
        label: 'Kapadokya',
        icon: Icons.landscape_rounded,
        // Warm amber sunrise → soft peach → lavender
        colors: [Color(0xFFF4974A), Color(0xFFFFBF7A), Color(0xFFD6BCE8)],
      ),
      'mersin_coast' => const _TourVisualSpec(
        label: 'Mersin Sahil',
        icon: Icons.waves_rounded,
        // Mediterranean teal → sky blue → light
        colors: [Color(0xFF3D8EC4), Color(0xFF6DC4B8), Color(0xFFBFE8EC)],
      ),
      'adana_culture' => const _TourVisualSpec(
        label: 'Adana Kültür',
        icon: Icons.account_balance_rounded,
        // Terracotta → warm amber → light peach
        colors: [Color(0xFFB85C38), Color(0xFFD9845A), Color(0xFFF5C89A)],
      ),
      'international_city' => const _TourVisualSpec(
        label: 'Yurt Dışı',
        icon: Icons.public_rounded,
        // Royal indigo → soft purple → sky
        colors: [Color(0xFF4F46E5), Color(0xFF8B7FEC), Color(0xFFBDD5F5)],
      ),
      _ => const _TourVisualSpec(
        label: 'Tur İzim',
        icon: Icons.travel_explore_rounded,
        // Blue → medium lavender → light
        colors: [Color(0xFF4A7DB5), Color(0xFF7EA8D4), Color(0xFFCCDFF5)],
      ),
    };
  }
}
