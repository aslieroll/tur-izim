import 'package:flutter/material.dart';

import 'package:tur_izim/shared/models/creator_profile.dart';
import 'package:tur_izim/shared/models/rated_application.dart';
import 'package:tur_izim/shared/models/student_verification_status.dart';
import 'package:tur_izim/shared/models/tour_detail.dart';
import 'package:tur_izim/shared/presentation/creator_profile_preview_bullets.dart';
import 'package:tur_izim/shared/presentation/status_label_turkish.dart';
import 'package:tur_izim/shared/presentation/travel_eligibility_labels_turkish.dart';
import 'package:tur_izim/shared/theme/tur_izim_design_tokens.dart';
import 'package:tur_izim/shared/widgets/tur_izim_info_banner.dart';
import 'package:tur_izim/shared/widgets/tur_izim_primary_button.dart';
import 'package:tur_izim/shared/widgets/tur_izim_secondary_button.dart';
import 'package:tur_izim/shared/widgets/tur_izim_surface_card.dart';
import 'package:tur_izim/shared/widgets/tur_izim_status_pill.dart';
import 'package:tur_izim/shared/widgets/suitability_score_card.dart';

/// Acente — başvuran öğrenci içerik üreticisi detayı (ek rota; ana rota değişmez).
class AgencyRatedApplicantDetailScreen extends StatelessWidget {
  const AgencyRatedApplicantDetailScreen({
    required this.rated,
    required this.tour,
    required this.canSelect,
    required this.onManualSelect,
    super.key,
  });

  final RatedApplication rated;
  final TourDetail? tour;
  final bool canSelect;
  final Future<void> Function() onManualSelect;

  @override
  Widget build(BuildContext context) {
    final c = rated.creator;

    return Scaffold(
      backgroundColor: TurIzimPalette.warmWhite,
      appBar: AppBar(
        backgroundColor: TurIzimPalette.warmWhite,
        foregroundColor: TurIzimPalette.deepNavy,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Aday profili',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: TurIzimPalette.deepNavy,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final inset = constraints.maxWidth >
                  TurIzimDesignTokens.maxReadableWidth + 48
              ? (constraints.maxWidth - TurIzimDesignTokens.maxReadableWidth) / 2
              : TurIzimDesignTokens.pageMargin;
          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  inset,
                  TurIzimDesignTokens.stackSmall,
                  inset,
                  TurIzimDesignTokens.stackLarge,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      TurIzimInfoBanner(
                        tone: TurIzimStatusTone.warning,
                        icon: Icons.person_search_rounded,
                        title: 'Manuel seçim',
                        message:
                            'Üniversite öğrencisi içerik üreticileri arasında '
                            'seçiminiz tamamen manuel yapılır. Aday Uygunluk Endeksi '
                            'bir karar destek bilgisidir; otomatik atama akışı yoktur.',
                      ),
                      const SizedBox(height: TurIzimDesignTokens.stackMedium),
                      TurIzimSurfaceCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    c.displayName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: TurIzimPalette.deepNavy,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                ),
                                TurIzimStatusPill(
                                  tone: TurIzimStatusTone.neutral,
                                  label: applicationStatusLabelTurkish(
                                    rated.summary.status,
                                  ),
                                ),
                              ],
                            ),
                            if (c.studentProfileLine != null) ...[
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.school_outlined,
                                    size: 20,
                                    color: TurIzimPalette.royalIndigo,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      c.studentProfileLine!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            height: 1.35,
                                          ),
                                    ),
                                  ),
                                  TurIzimStatusPill(
                                    tone: c.studentVerificationStatus ==
                                            StudentVerificationStatus.verified
                                        ? TurIzimStatusTone.success
                                        : TurIzimStatusTone.neutral,
                                    label: studentVerificationStatusLabel(
                                      c.studentVerificationStatus,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _studentExpandedLabels(c),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.onSurfaceVariant,
                                      height: 1.42,
                                    ),
                              ),
                            ] else ...[
                              const SizedBox(height: 8),
                              Text(
                                'Bu aday için üniversite veya bölüm bilgisi beyan '
                                'edilmemiş (zorunlu değil).',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.onSurfaceVariant,
                                      height: 1.35,
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: TurIzimDesignTokens.stackMedium),
                      SuitabilityScoreCard(scores: rated.scores),
                      const SizedBox(height: TurIzimDesignTokens.stackMedium),
                      TurIzimSurfaceCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pasaport ve vize beyanları',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: TurIzimPalette.deepNavy,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Bunlar yurt dışı ilanların ön bildirimi ve kapısı '
                                  'için gösterilir; Aday Uygunluk Endeksi bileşeni '
                                  'değildir.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: TurIzimPalette.mutedText,
                                    height: 1.42,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            _kv(
                              context,
                              'Pasaport tipi',
                              passportTypeLabelTurkish(c.passportType),
                            ),
                            _kv(
                              context,
                              'Pasaport durumu beyanı',
                              c.hasValidPassport
                                  ? 'Geçerliliği beyanı (MVP doğrulanmıyor)'
                                  : 'Beyanı yok / geçersiz beyan',
                            ),
                            _kv(
                              context,
                              'Vize durumu beyanı',
                              visaEligibilityLabelTurkish(c.visaEligibility),
                            ),
                            if (tour?.tourScope != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  'İlan coğrafyası: ${tourScopeLabelTurkish(tour!.tourScope)} '
                                  '(otomatik seçim yapılmaz).',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color:
                                            Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (rated.summary.message != null &&
                          rated.summary.message!.trim().isNotEmpty) ...[
                        const SizedBox(height: TurIzimDesignTokens.stackMedium),
                        TurIzimSurfaceCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Başvuru metni',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: TurIzimPalette.deepNavy,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(rated.summary.message!),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: TurIzimDesignTokens.stackMedium),
                      if (creatorProfileMockPreviewBullets(c).isNotEmpty)
                        TurIzimSurfaceCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Profil özetleri (mock)',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: TurIzimPalette.deepNavy,
                                    ),
                              ),
                              const SizedBox(height: 10),
                              ...creatorProfileMockPreviewBullets(c).map(
                                (b) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    '· $b',
                                    style:
                                        Theme.of(context).textTheme.bodySmall?.copyWith(
                                              height: 1.42,
                                            ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (!canSelect) ...[
                        const SizedBox(height: TurIzimDesignTokens.stackMedium),
                        TurIzimSecondaryButton(
                          label: 'Kapat',
                          icon: Icons.close_rounded,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ] else ...[
                        const SizedBox(height: TurIzimDesignTokens.stackMedium),
                        TurIzimPrimaryButton(
                          icon: Icons.how_to_reg_rounded,
                          label: 'Seçimi onayla',
                          onPressed: () async {
                            await onManualSelect();
                            if (!context.mounted) return;
                            Navigator.of(context).pop();
                          },
                        ),
                        const SizedBox(height: TurIzimDesignTokens.stackSmall),
                        TurIzimSecondaryButton(
                          label: 'Kapat',
                          icon: Icons.close_rounded,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _kv(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: TurIzimPalette.mutedText,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.35,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.38,
                ),
          ),
        ],
      ),
    );
  }

  String _studentExpandedLabels(CreatorProfile c) {
    final parts = <String>[];
    if (c.universityName != null && c.universityName!.trim().isNotEmpty) {
      parts.add('Üniversite: ${c.universityName}');
    }
    if (c.departmentName != null && c.departmentName!.trim().isNotEmpty) {
      parts.add('Bölüm: ${c.departmentName}');
    }
    if (c.classYear != null) {
      parts.add('Sınıf: ${c.classYear}');
    }
    if (c.campusCity != null && c.campusCity!.trim().isNotEmpty) {
      parts.add('Kampüs / şehir: ${c.campusCity}');
    }
    return parts.isEmpty ? '(Ayrıştırılmış alan görünmüyor.)' : parts.join('\n');
  }
}
