import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tur_izim/app/router.dart';
import 'package:tur_izim/app/tur_izim_scope.dart';
import 'package:tur_izim/core/constants/app_constants.dart';
import 'package:tur_izim/core/di/tur_izim_dependencies.dart';
import 'package:tur_izim/features/auth/data/session_auth_repository.dart';
import 'package:tur_izim/features/auth/domain/auth_repository.dart';
import 'package:tur_izim/shared/models/user_role.dart';
import 'package:tur_izim/shared/theme/tur_izim_design_tokens.dart';

/// Karşılama: rol seçimi ve yönlendirme (kimlik doğrulama yalnızca mock).
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = TurIzimScope.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Layer 1: full-screen sky-to-lavender gradient + decorative orbs
          const Positioned.fill(child: _BackgroundLayer()),
          // Layer 2: content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.pageHorizontalMargin,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title + slogan, vertically centered in the upper space
                  Expanded(
                    child: Center(
                      child: _HeaderSection(slogan: _slogan, description: _description),
                    ),
                  ),
                  // Glassmorphism button card (pinned to bottom)
                  _ButtonCard(
                    onCreator: () => _enter(context, session, UserRole.creator),
                    onAgency: () => _enter(context, session, UserRole.agency),
                    onAdmin: () => _enter(context, session, UserRole.admin),
                  ),
                  const SizedBox(height: 16),
                  // MVP note — tiny, muted, centered
                  Text(
                    _mvpNote,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.65),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _enter(
    BuildContext context,
    AuthRepository session,
    UserRole role,
  ) async {
    final target = switch (role) {
      UserRole.creator => AppRoutes.creatorHome,
      UserRole.agency => AppRoutes.agencyHome,
      UserRole.admin => AppRoutes.adminHome,
    };

    await session.selectRole(role);
    if (context.mounted && session is SessionAuthRepository) {
      final api = TurIzimDependencies.of(context).apiClient;
      await session.primeDemoIdentityFromApi(api);
    }
    if (!context.mounted) return;
    context.go(target);
  }
}

// ---------------------------------------------------------------------------
// Background
// ---------------------------------------------------------------------------

/// Soft Sky Blue → Warm White → Soft Lavender gradient with decorative orbs.
class _BackgroundLayer extends StatelessWidget {
  const _BackgroundLayer();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base gradient (travel-horizon feel)
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
        // Orb: top-left large indigo
        Positioned(
          top: -80,
          left: -80,
          child: _orb(240, TurIzimPalette.royalIndigo.withValues(alpha: 0.07)),
        ),
        // Orb: top-right sky
        Positioned(
          top: 60,
          right: -50,
          child: _orb(170, TurIzimPalette.softSkyBlue.withValues(alpha: 0.6)),
        ),
        // Orb: mid-left coral accent
        Positioned(
          bottom: 260,
          left: -44,
          child: _orb(130, TurIzimPalette.softCoral.withValues(alpha: 0.12)),
        ),
        // Orb: bottom-right indigo
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
// Header
// ---------------------------------------------------------------------------

/// Centered title / slogan / description area.
class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.slogan, required this.description});

  final String slogan;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // App name — display-sized, italic, Royal Indigo (Stitch: font-display, italic)
        Text(
          AppConstants.appName,
          textAlign: TextAlign.center,
          style: theme.textTheme.displaySmall?.copyWith(
            color: TurIzimPalette.royalIndigo,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 14),
        // Coral accent line (Stitch: w-12 h-1 bg-primary-container rounded-full)
        Container(
          width: 48,
          height: 2.5,
          decoration: BoxDecoration(
            color: TurIzimPalette.softCoral,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 24),
        // Slogan — large, Deep Navy, bold (Stitch: text-h1, on-surface)
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
        // Description — body, muted (Stitch: text-body-lg, on-surface-variant)
        Text(
          description,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    ),
    );
  }
}

// ---------------------------------------------------------------------------
// Button card (glassmorphism)
// ---------------------------------------------------------------------------

/// Frosted-glass card holding role-selection CTAs (Stitch: backdrop-blur card).
class _ButtonCard extends StatelessWidget {
  const _ButtonCard({
    required this.onCreator,
    required this.onAgency,
    required this.onAdmin,
  });

  final VoidCallback onCreator;
  final VoidCallback onAgency;
  final VoidCallback onAdmin;

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
            // 62% white → frosted glass over the gradient
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
              // Primary: Creator — pill, Royal Indigo, trailing arrow
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
              // Secondary: Agency — pill, surface, leading icon, outlined
              _PillButton(
                label: 'Acente Olarak Devam Et',
                leadingIcon: Icons.business_center_outlined,
                backgroundColor: Colors.white.withValues(alpha: 0.80),
                foregroundColor: TurIzimPalette.deepNavy,
                onPressed: onAgency,
                borderColor: TurIzimPalette.deepNavy.withValues(alpha: 0.18),
              ),
              const SizedBox(height: 20),
              // Tertiary: Admin — small text link, centered (Stitch: label-caps, underline)
              GestureDetector(
                onTap: onAdmin,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    'Admin Girişi',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: TurIzimPalette.royalIndigo,
                      letterSpacing: 0.10,
                      decoration: TextDecoration.underline,
                      decorationColor: TurIzimPalette.royalIndigo.withValues(alpha: 0.45),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared pill button
// ---------------------------------------------------------------------------

/// Fully-rounded (pill) button per Stitch "rounded-full" button spec.
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
          side: borderColor != null ? BorderSide(color: borderColor!) : BorderSide.none,
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
