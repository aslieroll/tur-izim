import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tur_izim/app/router.dart';
import 'package:tur_izim/shared/theme/tur_izim_design_tokens.dart';
import 'package:tur_izim/shared/widgets/tur_izim_primary_button.dart';
import 'package:tur_izim/shared/widgets/tur_izim_secondary_button.dart';
import 'package:tur_izim/shared/widgets/tur_izim_surface_card.dart';

/// JWT oturumu olmadan korumalı alanlarda gösterilen güvenli durum.
class AuthRequiredPanel extends StatelessWidget {
  const AuthRequiredPanel({
    super.key,
    this.title = 'Devam etmek için giriş yapın',
    this.message =
        'Bu alan hesabınızla oturum açmanızı gerektirir. '
        'Hızlı demo girişi yalnızca genel tur listesini gösterir.',
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TurIzimDesignTokens.pageMargin),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: TurIzimSurfaceCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 48,
                  color: TurIzimPalette.royalIndigo.withValues(alpha: 0.85),
                ),
                const SizedBox(height: TurIzimDesignTokens.stackMedium),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: TurIzimPalette.deepNavy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: TurIzimPalette.mutedText,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: TurIzimDesignTokens.stackLarge),
                TurIzimPrimaryButton(
                  label: 'Giriş yap',
                  icon: Icons.login_rounded,
                  onPressed: () => context.push(AppRoutes.login),
                ),
                const SizedBox(height: 10),
                TurIzimSecondaryButton(
                  label: 'Üretici kaydı oluştur',
                  icon: Icons.person_add_alt_1_rounded,
                  fullWidth: true,
                  onPressed: () => context.push(AppRoutes.registerCreator),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.go(AppRoutes.welcome),
                  child: const Text('Karşılama ekranına dön'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
