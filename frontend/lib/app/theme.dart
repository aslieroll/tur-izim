import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../shared/theme/tur_izim_design_tokens.dart';

/// Tur İzim — Premium Travel Pass tema kabuğu (Slice A).
/// Renkler `TurIzimPalette` / `ColorScheme`; başarı ve uyarı `TurIzimSemanticColors` extension ile.
abstract final class TurIzimTheme {
  TurIzimTheme._();

  static ThemeData get light {
    final colorScheme = _premiumColorScheme;
    final textTheme = _premiumTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      extensions: const [TurIzimSemanticColors.light],
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerHighest,
        elevation: 2,
        shadowColor: TurIzimPalette.deepNavy.withValues(alpha: 0.06),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: textTheme.labelLarge?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.05,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: TurIzimPalette.deepNavy,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: TurIzimPalette.deepNavy.withValues(alpha: 0.2),
        indicatorColor: TurIzimPalette.softCoral.withValues(alpha: 0.35),
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? TurIzimPalette.softCoral : Colors.white.withValues(alpha: 0.75),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? TurIzimPalette.softCoral : Colors.white.withValues(alpha: 0.75),
            size: 24,
          );
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shadowColor: TurIzimPalette.deepNavy.withValues(alpha: 0.12),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.onSurface.withValues(alpha: 0.12),
          disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(double.infinity, AppConstants.minTouchTarget),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.02,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.secondary,
          disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
          side: BorderSide(color: colorScheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(double.infinity, AppConstants.minTouchTarget),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(48, AppConstants.minTouchTarget),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static ColorScheme get _premiumColorScheme {
    return ColorScheme.fromSeed(
      seedColor: TurIzimPalette.royalIndigo,
      brightness: Brightness.light,
    ).copyWith(
      primary: TurIzimPalette.royalIndigo,
      onPrimary: Colors.white,
      primaryContainer: TurIzimPalette.softLavender,
      onPrimaryContainer: TurIzimPalette.deepNavy,
      secondary: TurIzimPalette.deepNavy,
      onSecondary: Colors.white,
      secondaryContainer: TurIzimPalette.softSkyBlue,
      onSecondaryContainer: TurIzimPalette.deepNavy,
      tertiary: TurIzimPalette.softCoral,
      onTertiary: Colors.white,
      tertiaryContainer: TurIzimPalette.sandCream,
      onTertiaryContainer: TurIzimPalette.slateText,
      error: TurIzimPalette.errorRed,
      onError: Colors.white,
      errorContainer: const Color(0xFFFFE4E6),
      onErrorContainer: const Color(0xFF991B1B),
      surface: TurIzimPalette.warmWhite,
      onSurface: TurIzimPalette.slateText,
      onSurfaceVariant: TurIzimPalette.mutedText,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: TurIzimPalette.warmWhite,
      surfaceContainer: TurIzimPalette.sandCream,
      surfaceContainerHigh: TurIzimPalette.softLavender,
      surfaceContainerHighest: TurIzimPalette.sandCream,
      outline: TurIzimPalette.mutedText.withValues(alpha: 0.45),
      outlineVariant: const Color(0xFFE5E7EB),
      shadow: TurIzimPalette.deepNavy.withValues(alpha: 0.18),
      scrim: TurIzimPalette.deepNavy.withValues(alpha: 0.45),
      inverseSurface: TurIzimPalette.deepNavy,
      onInverseSurface: TurIzimPalette.warmWhite,
      inversePrimary: TurIzimPalette.softLavender,
      surfaceTint: TurIzimPalette.royalIndigo.withValues(alpha: 0.12),
    );
  }

  static TextTheme _premiumTextTheme() {
    const navy = TurIzimPalette.deepNavy;
    const slate = TurIzimPalette.slateText;
    const muted = TurIzimPalette.mutedText;

    return TextTheme(
      displayLarge: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 34,
        height: 1.24,
        letterSpacing: -0.02,
        color: navy,
      ),
      displayMedium: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 30,
        height: 1.27,
        letterSpacing: -0.02,
        color: navy,
      ),
      displaySmall: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 26,
        height: 1.3,
        color: navy,
      ),
      headlineLarge: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 28,
        height: 1.29,
        color: navy,
      ),
      headlineMedium: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 24,
        height: 1.25,
        color: navy,
      ),
      headlineSmall: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 20,
        height: 1.3,
        color: navy,
      ),
      titleLarge: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 18,
        height: 1.35,
        color: slate,
      ),
      titleMedium: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        height: 1.35,
        color: slate,
      ),
      titleSmall: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        height: 1.35,
        color: slate,
      ),
      bodyLarge: const TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 16,
        height: 1.5,
        color: slate,
      ),
      bodyMedium: const TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 14,
        height: 1.45,
        color: slate,
      ),
      bodySmall: const TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 12,
        height: 1.4,
        color: muted,
      ),
      labelLarge: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        height: 1.25,
        letterSpacing: 0.02,
        color: slate,
      ),
      labelMedium: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 12,
        height: 1.25,
        letterSpacing: 0.05,
        color: muted,
      ),
      labelSmall: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 11,
        height: 1.2,
        letterSpacing: 0.05,
        color: muted,
      ),
    );
  }
}
