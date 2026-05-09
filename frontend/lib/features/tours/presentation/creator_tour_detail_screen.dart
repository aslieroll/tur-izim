import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tur_izim/app/router.dart';
import 'package:tur_izim/app/tur_izim_scope.dart';
import 'package:tur_izim/core/constants/app_constants.dart';
import 'package:tur_izim/core/di/tur_izim_dependencies.dart';
import 'package:tur_izim/shared/models/tour_detail.dart';
import 'package:tur_izim/shared/models/tour_scope.dart';
import 'package:tur_izim/shared/models/tour_status.dart';
import 'package:tur_izim/shared/presentation/status_label_turkish.dart';
import 'package:tur_izim/shared/presentation/travel_eligibility_labels_turkish.dart';
import 'package:tur_izim/shared/presentation/tour_display_format.dart';
import 'package:tur_izim/shared/presentation/tour_requirement_labels_turkish.dart';
import 'package:tur_izim/shared/presentation/turkish_lira_format.dart';
import 'package:tur_izim/shared/theme/tur_izim_design_tokens.dart';
import 'package:tur_izim/shared/widgets/international_mandatory_requirements_card.dart';
import 'package:tur_izim/shared/widgets/publication_commitment_info_card.dart';
import 'package:tur_izim/shared/widgets/tour_visual_header.dart';
import 'package:tur_izim/shared/widgets/tur_izim_info_banner.dart';
import 'package:tur_izim/shared/widgets/tur_izim_primary_button.dart';
import 'package:tur_izim/shared/widgets/tur_izim_section_header.dart';
import 'package:tur_izim/shared/widgets/tur_izim_status_pill.dart';
import 'package:tur_izim/shared/widgets/tur_izim_surface_card.dart';

/// Creator-facing tur özeti + başvuru formuna geçiş (Aşama 2.4).
class CreatorTourDetailScreen extends StatefulWidget {
  const CreatorTourDetailScreen({required this.tourId, super.key});

  final String tourId;

  @override
  State<CreatorTourDetailScreen> createState() =>
      _CreatorTourDetailScreenState();
}

class _CreatorTourDetailScreenState extends State<CreatorTourDetailScreen> {
  Future<({TourDetail? detail, bool applied, bool eligible})>? _bundle;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bundle ??= _load();
  }

  Future<({TourDetail? detail, bool applied, bool eligible})> _load() async {
    final deps = TurIzimDependencies.of(context);
    final session = TurIzimScope.of(context);
    final creatorId = session.activeCreatorId!;
    final tour = await deps.tours.fetchTourDetail(widget.tourId);
    final applied = tour == null
        ? false
        : await deps.tours.hasCreatorApplied(
            tourId: widget.tourId,
            creatorId: creatorId,
          );
    final eligible = tour == null
        ? false
        : await deps.tours.isCreatorEligibleForTour(
            creatorId: creatorId,
            tourId: widget.tourId,
          );
    return (detail: tour, applied: applied, eligible: eligible);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tur detayı')),
      body: FutureBuilder<({TourDetail? detail, bool applied, bool eligible})>(
        future: _bundle,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting ||
              snap.data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final tour = snap.data!.detail;
          final applied = snap.data!.applied;
          final eligible = snap.data!.eligible;
          if (tour == null) {
            return const Center(child: Text('Tur bulunamadı.'));
          }

          final agencyLine = agencyDisplayLineWithCityTurkish(tour);
          final canOpenForm =
              tour.isOpenForApplications && !applied && eligible;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.pageHorizontalMargin,
              20,
              AppConstants.pageHorizontalMargin,
              32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TourDetailHero(tour: tour, agencyLine: agencyLine),
                const SizedBox(height: 20),
                _ValueCard(tour: tour),
                const SizedBox(height: 20),
                InternationalMandatoryRequirementsCard(tour: tour),
                if (tour.tourScope == TourScope.international)
                  const SizedBox(height: 20),
                _DescriptionCard(tour: tour),
                const SizedBox(height: 20),
                _RequirementsCard(tour: tour),
                const SizedBox(height: 20),
                const TurIzimSectionHeader(
                  overline: 'Başvuru öncesi',
                  title: '30 günlük yayın taahhüdü',
                  subtitle:
                      'Başvuru ve son onay adımlarında koşullar ayrıca manuel olarak işaretlenir.',
                ),
                const SizedBox(height: 12),
                const PublicationCommitmentInfoCard(),
                const SizedBox(height: 20),
                _ApplicationCtaCard(
                  applied: applied,
                  eligible: eligible,
                  isInternational: tour.tourScope == TourScope.international,
                  isOpenForApplications: tour.isOpenForApplications,
                  canOpenForm: canOpenForm,
                  onApply: () =>
                      context.push(AppRoutes.creatorApply(widget.tourId)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Tour detail hero — large visual at top, tour info below
// ═══════════════════════════════════════════════════════════════════════════

class _TourDetailHero extends StatelessWidget {
  const _TourDetailHero({required this.tour, required this.agencyLine});

  final TourDetail tour;
  final String agencyLine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Outer container clips the whole hero (visual + info area) with one radius.
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(TurIzimDesignTokens.radiusLarge),
        color: theme.colorScheme.surfaceContainerLowest,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
        boxShadow: TurIzimDesignTokens.premiumShadow(),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(TurIzimDesignTokens.radiusLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Large visual area at the top of the hero ─────────────────
            TourVisualHeader(
              tour: tour,
              height: 220,
              // No extra clip — outer ClipRRect handles the top corners.
              borderRadius: BorderRadius.zero,
              showLabel: true,
              showTitleOverlay: false,
            ),

            // ── Tour info section below the visual ───────────────────────
            Padding(
              padding: const EdgeInsets.all(TurIzimDesignTokens.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      TurIzimStatusPill(
                        label: tourStatusLabelTurkish(tour.status),
                        tone: _statusTone(tour.status),
                      ),
                      TurIzimStatusPill(
                        label: tourScopeLabelTurkish(tour.tourScope),
                        tone: tour.tourScope == TourScope.international
                            ? TurIzimStatusTone.warning
                            : TurIzimStatusTone.info,
                        icon: tour.tourScope == TourScope.international
                            ? Icons.public_rounded
                            : Icons.location_on_outlined,
                      ),
                      TurIzimStatusPill(
                        label: tour.transportationIncluded
                            ? 'Ulaşım dahil'
                            : 'Ulaşım hariç',
                        tone: tour.transportationIncluded
                            ? TurIzimStatusTone.success
                            : TurIzimStatusTone.neutral,
                        icon: Icons.directions_bus_filled_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    tour.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: TurIzimPalette.deepNavy,
                      fontWeight: FontWeight.w800,
                      height: 1.22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Acente: $agencyLine',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _HeroInfoLine(
                    icon: Icons.location_city_outlined,
                    label: 'Çıkış şehri: ${tour.departureCity}',
                  ),
                  const SizedBox(height: 8),
                  _HeroInfoLine(
                    icon: Icons.route_rounded,
                    label: 'Tur rotası: ${tourRouteOverviewLineTurkish(tour)}',
                  ),
                  const SizedBox(height: 8),
                  _HeroInfoLine(
                    icon: Icons.calendar_month_outlined,
                    label:
                        '${formatTourCalendarDate(tour.startsAt)} – ${formatTourCalendarDate(tour.endsAt)}',
                  ),
                  const SizedBox(height: 8),
                  _HeroInfoLine(
                    icon: Icons.event_seat_outlined,
                    label:
                        '${tour.seatsOffered} koltuk · Üretici kotası: ${tour.remainingCreatorSlots}/${tour.creatorQuota}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  TurIzimStatusTone _statusTone(TourStatus status) {
    return switch (status) {
      TourStatus.published => TurIzimStatusTone.success,
      TourStatus.applicationClosed => TurIzimStatusTone.warning,
      TourStatus.assigned => TurIzimStatusTone.info,
      TourStatus.completed => TurIzimStatusTone.neutral,
      TourStatus.cancelled => TurIzimStatusTone.danger,
      TourStatus.draft => TurIzimStatusTone.neutral,
    };
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Value card
// ═══════════════════════════════════════════════════════════════════════════

class _ValueCard extends StatelessWidget {
  const _ValueCard({required this.tour});

  final TourDetail tour;

  @override
  Widget build(BuildContext context) {
    return TurIzimSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TurIzimSectionHeader(
            overline: 'Güvence bilgisi',
            title: 'Değer ve depozito',
            subtitle:
                'Depozito mock güvence adımıdır; üçüncü taraf doğrulama veya gerçek para hareketleri yürütülmez.',
          ),
          const SizedBox(height: 16),
          _ValueRow(
            label: 'Normal satış değeri',
            value: formatTurkishLiraAmount(
              tour.normalSalesPrice,
              currencyCode: tour.currency,
            ),
          ),
          const SizedBox(height: 10),
          _ValueRow(
            label: 'Beklenen depozito',
            value: formatTurkishLiraAmount(
              tour.expectedDepositAmount,
              currencyCode: tour.currency,
            ),
          ),
          const SizedBox(height: 14),
          const TurIzimInfoBanner(
            title: 'Gerçek ödeme yok',
            message:
                "MVP'de depozito yalnızca operasyon simülasyonudur; harici doğrulama veya üçüncü taraf tahsilat entegrasyonu yoktur.",
            tone: TurIzimStatusTone.info,
            icon: Icons.lock_outline_rounded,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Description card
// ═══════════════════════════════════════════════════════════════════════════

class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard({required this.tour});

  final TourDetail tour;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TurIzimSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TurIzimSectionHeader(overline: 'Tur özeti', title: 'Açıklama'),
          const SizedBox(height: 12),
          Text(
            tour.description,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.55),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Requirements card
// ═══════════════════════════════════════════════════════════════════════════

class _RequirementsCard extends StatelessWidget {
  const _RequirementsCard({required this.tour});

  final TourDetail tour;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TurIzimSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TurIzimSectionHeader(
            overline: 'Objektif kriterler',
            title: 'İçerik gereksinimleri',
            subtitle:
                'Revizyon talepleri yalnızca teknik checklist maddelerine dayanır.',
          ),
          const SizedBox(height: 14),
          if (tour.requirements.isEmpty)
            Text(
              'Bu ilanda ek gereksinim satırı yok.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tour.requirements
                  .map(
                    (requirement) => TurIzimStatusPill(
                      label: tourRequirementShortLabelTurkish(requirement),
                      tone: TurIzimStatusTone.neutral,
                      icon: Icons.check_circle_outline_rounded,
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Application CTA card
// ═══════════════════════════════════════════════════════════════════════════

class _ApplicationCtaCard extends StatelessWidget {
  const _ApplicationCtaCard({
    required this.applied,
    required this.eligible,
    required this.isInternational,
    required this.isOpenForApplications,
    required this.canOpenForm,
    required this.onApply,
  });

  final bool applied;
  final bool eligible;
  final bool isInternational;
  final bool isOpenForApplications;
  final bool canOpenForm;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final message = _blockedMessage();

    return TurIzimSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TurIzimSectionHeader(
            overline: 'Başvuru',
            title: 'Başvuru akışına geç',
            subtitle:
                'Başvuru formunda üç zorunlu onay kutusu ayrıca manuel olarak işaretlenir.',
          ),
          if (message != null) ...[
            const SizedBox(height: 14),
            TurIzimInfoBanner(
              title: 'Başvuru şu anda açılamıyor',
              message: message,
              tone: applied
                  ? TurIzimStatusTone.warning
                  : TurIzimStatusTone.danger,
              icon: Icons.info_outline_rounded,
            ),
          ],
          const SizedBox(height: 16),
          TurIzimPrimaryButton(
            label: 'Başvuruya Geç',
            icon: Icons.arrow_forward_rounded,
            onPressed: canOpenForm ? onApply : null,
          ),
        ],
      ),
    );
  }

  String? _blockedMessage() {
    if (applied) {
      return 'Bu ilana zaten başvurdunuz; tekrar başvuru gönderilemez.';
    }
    if (!eligible && isInternational) {
      return 'Bu yurt dışı turu için pasaport/vize uygunluğunuz bulunmuyor. Bu kontrol Aday Uygunluk Endeksi skoru değildir; ayrı başvuru kapısıdır.';
    }
    if (!isOpenForApplications) {
      return 'Bu tur için başvurular kota veya iş kuralı nedeniyle kapalı.';
    }
    return null;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Small helpers
// ═══════════════════════════════════════════════════════════════════════════

class _HeroInfoLine extends StatelessWidget {
  const _HeroInfoLine({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, color: TurIzimPalette.royalIndigo, size: 19),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: TurIzimPalette.deepNavy.withValues(alpha: 0.74),
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: TurIzimPalette.softLavender.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(TurIzimDesignTokens.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                color: TurIzimPalette.deepNavy,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
