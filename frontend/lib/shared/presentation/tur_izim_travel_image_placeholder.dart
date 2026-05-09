import 'package:flutter/material.dart';

/// Büyük seyahat görselleri için **yer tutucu** (MVP).
///
/// Stitch HTML’deki `Image.network` / stok URL’leri **doğrudan kullanmayın**:
/// üretimde lisanslı asset veya onaylı CDN kullanılmalıdır. Bu widget yalnızca
/// tema renkleriyle soyut bir “hero” alanı çizer; iş mantığı içermez.
class TurIzimTravelImagePlaceholder extends StatelessWidget {
  const TurIzimTravelImagePlaceholder({
    this.height = 168,
    super.key,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                scheme.secondaryContainer,
                scheme.primaryContainer,
              ],
            ),
          ),
          child: Icon(
            Icons.travel_explore_rounded,
            size: 56,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }
}
