import 'package:flutter/material.dart';

/// Premium Travel Pass — onaylı palet (tema + semantik extension).
/// UI etiketleri Türkçe kalır; teknik sabit adları İngilizce.
abstract final class TurIzimPalette {
  TurIzimPalette._();

  static const Color warmWhite = Color(0xFFFFFBF7);
  static const Color sandCream = Color(0xFFFFF4EC);
  static const Color softSkyBlue = Color(0xFFDCEBFF);
  static const Color softLavender = Color(0xFFEEF2FF);
  static const Color deepNavy = Color(0xFF1E2A5A);
  static const Color royalIndigo = Color(0xFF4F46E5);
  static const Color softCoral = Color(0xFFFF6B6B);
  static const Color slateText = Color(0xFF1F2937);
  static const Color mutedText = Color(0xFF6B7280);
  static const Color successGreen = Color(0xFF22C55E);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);
}

/// Material `ColorScheme` dışında kalan semantik renkler (başarı / uyarı / vurgu).
final class TurIzimSemanticColors extends ThemeExtension<TurIzimSemanticColors> {
  const TurIzimSemanticColors({
    required this.success,
    required this.warning,
    required this.coralAccent,
    required this.infoSurface,
    required this.infoSurfaceAlt,
  });

  final Color success;
  final Color warning;
  final Color coralAccent;
  final Color infoSurface;
  final Color infoSurfaceAlt;

  static const TurIzimSemanticColors light = TurIzimSemanticColors(
    success: TurIzimPalette.successGreen,
    warning: TurIzimPalette.warningAmber,
    coralAccent: TurIzimPalette.softCoral,
    infoSurface: TurIzimPalette.softSkyBlue,
    infoSurfaceAlt: TurIzimPalette.softLavender,
  );

  @override
  TurIzimSemanticColors copyWith({
    Color? success,
    Color? warning,
    Color? coralAccent,
    Color? infoSurface,
    Color? infoSurfaceAlt,
  }) {
    return TurIzimSemanticColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      coralAccent: coralAccent ?? this.coralAccent,
      infoSurface: infoSurface ?? this.infoSurface,
      infoSurfaceAlt: infoSurfaceAlt ?? this.infoSurfaceAlt,
    );
  }

  @override
  TurIzimSemanticColors lerp(
    ThemeExtension<TurIzimSemanticColors>? other,
    double t,
  ) {
    if (other is! TurIzimSemanticColors) return this;
    return TurIzimSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      coralAccent: Color.lerp(coralAccent, other.coralAccent, t)!,
      infoSurface: Color.lerp(infoSurface, other.infoSurface, t)!,
      infoSurfaceAlt: Color.lerp(infoSurfaceAlt, other.infoSurfaceAlt, t)!,
    );
  }
}

extension TurIzimSemanticColorsX on BuildContext {
  TurIzimSemanticColors get turIzimSemanticColors =>
      Theme.of(this).extension<TurIzimSemanticColors>() ??
      TurIzimSemanticColors.light;
}
