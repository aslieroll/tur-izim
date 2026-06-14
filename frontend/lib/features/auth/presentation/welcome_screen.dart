import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tur_izim/app/router.dart';
import 'package:tur_izim/app/tur_izim_scope.dart';
import 'package:tur_izim/core/constants/app_constants.dart';
import 'package:tur_izim/core/di/tur_izim_dependencies.dart';
import 'package:tur_izim/features/auth/data/session_auth_repository.dart';
import 'package:tur_izim/shared/models/user_role.dart';
import 'package:tur_izim/shared/theme/tur_izim_design_tokens.dart';

/// Karşılama: üst bar (gerçek auth) + hızlı rol girişi (demo / legacy).
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const String _slogan =
      'Boş koltukları güvenli içerik iş birliklerine dönüştür.';

  static const String _description =
      'Tur İzim, yerel tur acentelerinin boş koltuklarını; üniversite öğrencilerinin '
      'teknik şartları belirlenmiş fotoğraf/video içerikleri ve 30 günlük yayın '
      'taahhüdü karşılığında değerlendirmesini sağlayan şehir bazlı güvenli görev ve '
      'içerik teslim platformudur.';

  static const String _mvpNote =
      'MVP\u2019de sosyal akış, sohbet, konaklama veya uçuş ürün sunumu yoktur; '
      'uygulama içi video yükleme ve gerçek para hareketleri yoktur. Çıkış ve '
      'kampüs şehirleri beyana dayalıdır; otomatik konum doğrulaması yoktur.';

  static const double _navBreakpointWidth = 720;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = TurIzimScope.of(context);

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _BackgroundLayer()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPad = AppConstants.pageHorizontalMargin;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPad,
                        12,
                        horizontalPad,
                        8,
                      ),
                      child: _WelcomeTopNav(
                        wide: constraints.maxWidth >= _navBreakpointWidth,
                        onLogin: () => context.push(AppRoutes.login),
                        onRegisterCreator: () =>
                            context.push(AppRoutes.registerCreator),
                        onRegisterAgency: () =>
                            context.push(AppRoutes.registerAgency),
                        onAdminDemo: () =>
                            _enter(context, session, UserRole.admin),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: TurIzimDesignTokens.maxReadableWidth,
                          ),
                          child: SingleChildScrollView(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPad,
                            ),
                            child: _HeroSection(
                              slogan: _slogan,
                              description: _description,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPad),
                      child: Align(
                        alignment: Alignment.center,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _ButtonCard(
                                onCreator: () =>
                                    _enter(context, session, UserRole.creator),
                                onAgency: () =>
                                    _enter(context, session, UserRole.agency),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                _mvpNote,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.65),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _enter(
    BuildContext context,
    SessionAuthRepository session,
    UserRole role,
  ) async {
    final target = switch (role) {
      UserRole.creator => AppRoutes.creatorHome,
      UserRole.agency => AppRoutes.agencyHome,
      UserRole.admin => AppRoutes.adminHome,
    };

    await session.selectRole(role);
    if (context.mounted) {
      final api = TurIzimDependencies.of(context).apiClient;
      await session.primeDemoIdentityFromApi(api);
    }
    if (!context.mounted) return;
    context.go(target);
  }
}

// ---------------------------------------------------------------------------
// Top navigation
// ---------------------------------------------------------------------------

class _WelcomeTopNav extends StatelessWidget {
  const _WelcomeTopNav({
    required this.wide,
    required this.onLogin,
    required this.onRegisterCreator,
    required this.onRegisterAgency,
    required this.onAdminDemo,
  });

  final bool wide;
  final VoidCallback onLogin;
  final VoidCallback onRegisterCreator;
  final VoidCallback onRegisterAgency;
  final VoidCallback onAdminDemo;

  static const double _authButtonRadius = 10;
  static const EdgeInsets _authPadding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 10,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final brand = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.travel_explore_rounded,
          size: 26,
          color: TurIzimPalette.royalIndigo.withValues(alpha: 0.92),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            AppConstants.appName,
            style: theme.textTheme.titleLarge?.copyWith(
              color: TurIzimPalette.deepNavy,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    final loginStyle = TextButton.styleFrom(
      foregroundColor: TurIzimPalette.royalIndigo,
      padding: _authPadding,
      minimumSize: const Size(48, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_authButtonRadius),
      ),
    );

    final creatorStyle = FilledButton.styleFrom(
      backgroundColor: TurIzimPalette.royalIndigo,
      foregroundColor: Colors.white,
      padding: _authPadding,
      minimumSize: const Size(48, 40),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_authButtonRadius),
      ),
    );

    final agencyStyle = OutlinedButton.styleFrom(
      foregroundColor: TurIzimPalette.deepNavy,
      padding: _authPadding,
      minimumSize: const Size(48, 40),
      side: BorderSide(
        color: TurIzimPalette.deepNavy.withValues(alpha: 0.22),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_authButtonRadius),
      ),
    );

    final authRow = Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: wide ? WrapAlignment.end : WrapAlignment.start,
      spacing: 6,
      runSpacing: 8,
      children: [
        TextButton(
          onPressed: onLogin,
          style: loginStyle,
          child: const Text(
            'Giriş yap',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
          ),
        ),
        FilledButton(
          onPressed: onRegisterCreator,
          style: creatorStyle,
          child: const Text(
            'Üretici kaydı',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
          ),
        ),
        OutlinedButton(
          onPressed: onRegisterAgency,
          style: agencyStyle,
          child: const Text(
            'Acente kaydı',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
          ),
        ),
        TextButton(
          onPressed: onAdminDemo,
          style: TextButton.styleFrom(
            foregroundColor: TurIzimPalette.mutedText,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            minimumSize: const Size(48, 36),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_authButtonRadius),
            ),
          ),
          child: Text(
            'Admin Girişi',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: TurIzimPalette.mutedText,
              decoration: TextDecoration.underline,
              decorationColor: TurIzimPalette.mutedText.withValues(alpha: 0.4),
            ),
          ),
        ),
      ],
    );

    if (wide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: brand,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Align(
              alignment: Alignment.centerRight,
              child: authRow,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        brand,
        const SizedBox(height: 12),
        authRow,
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Background
// ---------------------------------------------------------------------------

class _BackgroundLayer extends StatelessWidget {
  const _BackgroundLayer();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                TurIzimPalette.softSkyBlue,
                TurIzimPalette.warmWhite,
                TurIzimPalette.softLavender,
              ],
              stops: [0.0, 0.48, 1.0],
            ),
          ),
        ),
        Positioned(
          top: -80,
          left: -80,
          child: _orb(240, TurIzimPalette.royalIndigo.withValues(alpha: 0.07)),
        ),
        Positioned(
          top: 60,
          right: -50,
          child: _orb(170, TurIzimPalette.softSkyBlue.withValues(alpha: 0.6)),
        ),
        Positioned(
          bottom: 260,
          left: -44,
          child: _orb(130, TurIzimPalette.softCoral.withValues(alpha: 0.12)),
        ),
        Positioned(
          bottom: -60,
          right: -60,
          child: _orb(210, TurIzimPalette.royalIndigo.withValues(alpha: 0.06)),
        ),
      ],
    );
  }

  Widget _orb(double size, Color color) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero (slogan + açıklama)
// ---------------------------------------------------------------------------

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.slogan, required this.description});

  final String slogan;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 2.5,
          decoration: BoxDecoration(
            color: TurIzimPalette.softCoral,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          slogan,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: TurIzimPalette.deepNavy,
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          description,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// CTA card (demo / hızlı rol)
// ---------------------------------------------------------------------------

class _ButtonCard extends StatelessWidget {
  const _ButtonCard({required this.onCreator, required this.onAgency});

  final VoidCallback onCreator;
  final VoidCallback onAgency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.62),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: TurIzimPalette.royalIndigo.withValues(alpha: 0.10),
            ),
            boxShadow: [
              BoxShadow(
                color: TurIzimPalette.deepNavy.withValues(alpha: 0.08),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _PillButton(
                label: 'İçerik Üreticisi Olarak Devam Et',
                trailingIcon: Icons.arrow_forward_rounded,
                backgroundColor: TurIzimPalette.royalIndigo,
                foregroundColor: Colors.white,
                onPressed: onCreator,
                elevation: 4,
                shadowColor: TurIzimPalette.royalIndigo.withValues(alpha: 0.28),
              ),
              const SizedBox(height: 12),
              _PillButton(
                label: 'Acente Olarak Devam Et',
                leadingIcon: Icons.business_center_outlined,
                backgroundColor: Colors.white.withValues(alpha: 0.80),
                foregroundColor: TurIzimPalette.deepNavy,
                onPressed: onAgency,
                borderColor: TurIzimPalette.deepNavy.withValues(alpha: 0.18),
              ),
              const SizedBox(height: 12),
              Text(
                'Hızlı deneyim: aşağıdaki düğmeler demo oturumu açar; '
                'hesabınızla devam etmek için üstten giriş veya kayıt kullanın.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.72,
                  ),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.borderColor,
    this.elevation = 0,
    this.shadowColor,
  });

  final String label;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;
  final Color? borderColor;
  final double elevation;
  final Color? shadowColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        elevation: elevation,
        shadowColor: shadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
          side: borderColor != null
              ? BorderSide(color: borderColor!)
              : BorderSide.none,
        ),
        minimumSize: const Size(double.infinity, 52),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingIcon != null) ...[
            Icon(leadingIcon, size: 20, color: foregroundColor),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelLarge?.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          if (trailingIcon != null) ...[
            const SizedBox(width: 8),
            Icon(trailingIcon, size: 18, color: foregroundColor),
          ],
        ],
      ),
    );
  }
}
