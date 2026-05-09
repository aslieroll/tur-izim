import 'package:flutter/material.dart';

import 'package:tur_izim/core/constants/app_constants.dart';
import 'package:tur_izim/core/di/tur_izim_dependencies.dart';
import 'package:tur_izim/core/errors/app_exception.dart';
import 'package:tur_izim/shared/models/pending_agency_review.dart';
import 'package:tur_izim/shared/presentation/agency_status_label_turkish.dart';
import 'package:tur_izim/shared/theme/tur_izim_design_tokens.dart';
import 'package:tur_izim/shared/widgets/tur_izim_info_banner.dart';
import 'package:tur_izim/shared/widgets/tur_izim_primary_button.dart';
import 'package:tur_izim/shared/widgets/tur_izim_secondary_button.dart';
import 'package:tur_izim/shared/widgets/tur_izim_status_pill.dart';
import 'package:tur_izim/shared/widgets/tur_izim_surface_card.dart';

/// Manuel acente onboarding incelemesi (mock repository).
class AdminAgencyApprovalDetailScreen extends StatelessWidget {
  const AdminAgencyApprovalDetailScreen({required this.agency, super.key});

  final PendingAgencyReview agency;

  Future<void> _decide(BuildContext context, bool approve) async {
    final deps = TurIzimDependencies.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(approve ? 'Onayı doğrula' : 'Ret talebini doğrula'),
        content: Text(
          approve
              ? '${agency.legalName} işletmesini onaylı acente olarak '
                  'işaretlemek üzeresiniz. Yayın hakları aktifleşebilir (mock).'
              : '${agency.legalName} işletmesinin onboarding başvurusunu '
                  'reddetmek üzeresiniz. Bu aksiyon yalnızca manuel karar ile '
                  'alınır.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(approve ? 'Onayla' : 'Reddet'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    try {
      await deps.adminDashboard.setAgencyApproval(
        agencyId: agency.id,
        approve: approve,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            approve
                ? 'Acente onay kararı kaydedildi (mock).'
                : 'Acente ret kararı kaydedildi (mock).',
          ),
        ),
      );
      Navigator.of(context).pop(true);
    } on AppException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: TurIzimPalette.warmWhite,
      appBar: AppBar(
        backgroundColor: TurIzimPalette.warmWhite,
        foregroundColor: TurIzimPalette.deepNavy,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Acente onayı',
          style: theme.textTheme.titleMedium?.copyWith(
            color: TurIzimPalette.deepNavy,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.pageHorizontalMargin,
          20,
          AppConstants.pageHorizontalMargin,
          32,
        ),
        children: [
          TurIzimSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  agency.legalName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: TurIzimPalette.deepNavy,
                  ),
                ),
                const SizedBox(height: 12),
                TurIzimStatusPill(
                  icon: Icons.verified_rounded,
                  label: agencyStatusLabelTurkish(agency.status),
                  tone: TurIzimStatusTone.warning,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const TurIzimInfoBanner(
            tone: TurIzimStatusTone.info,
            icon: Icons.policy_rounded,
            title: 'Yayımlama politikası',
            message:
                'Sadece onaylı acenteler tur ilanı yayımlayabilir ve '
                    'üniversite öğrencisi içerik üreticisi başvurularını listeleyebilir.',
          ),
          const SizedBox(height: 28),
          TurIzimPrimaryButton(
            label: 'Onayla',
            icon: Icons.check_circle_outline_rounded,
            onPressed: () => _decide(context, true),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => _decide(context, false),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(
                color: theme.colorScheme.error.withValues(alpha: 0.45),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                'Reddet',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ),
          const SizedBox(height: TurIzimDesignTokens.stackMedium),
          TurIzimSecondaryButton(
            label: 'Vazgeç',
            icon: Icons.arrow_back_rounded,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
