import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tur_izim/app/router.dart';
import 'package:tur_izim/app/tur_izim_scope.dart';
import 'package:tur_izim/core/constants/app_constants.dart';
import 'package:tur_izim/core/di/tur_izim_dependencies.dart';
import 'package:tur_izim/shared/models/tour_scope.dart';
import 'package:tur_izim/shared/models/tour_summary.dart';
import 'package:tur_izim/shared/models/tour_status.dart';
import 'package:tur_izim/shared/models/creator_home_peek.dart';
import 'package:tur_izim/shared/presentation/status_label_turkish.dart';
import 'package:tur_izim/shared/presentation/travel_eligibility_labels_turkish.dart';
import 'package:tur_izim/shared/presentation/tour_display_format.dart';
import 'package:tur_izim/shared/presentation/turkish_lira_format.dart';
import 'package:tur_izim/shared/theme/tur_izim_design_tokens.dart';
import 'package:tur_izim/shared/widgets/tur_izim_primary_button.dart';
import 'package:tur_izim/shared/widgets/tur_izim_section_header.dart';
import 'package:tur_izim/shared/widgets/tur_izim_status_pill.dart';
import 'package:tur_izim/shared/widgets/tur_izim_surface_card.dart';
import 'package:tur_izim/shared/widgets/tour_visual_header.dart';

class CreatorOpenToursScreen extends StatelessWidget {
  const CreatorOpenToursScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deps = TurIzimDependencies.of(context);
    final session = TurIzimScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('İlanlar (yayımda)'),
        actions: [
          TextButton(
            onPressed: () => context.push(AppRoutes.creatorAssignments),
            child: const Text('Görevlerim'),
          ),
          TextButton(
            onPressed: () => context.push(AppRoutes.creatorApplications),
            child: const Text('Başvurularım'),
          ),
          TextButton(
            onPressed: () async {
              await session.clearSession();
              if (context.mounted) {
                context.go(AppRoutes.welcome);
              }
            },
            child: const Text('Çıkış'),
          ),
        ],
      ),
      body: FutureBuilder<({List<TourSummary> tours, CreatorHomePeek peek})>(
        future: () async {
          final creatorId = session.activeCreatorId!;
          final tours = await deps.tours.fetchPublishedToursForCreator(creatorId);
          final peek = await deps.creatorDashboard.loadHomePeek(creatorId);
          return (tours: tours, peek: peek);
        }(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('Turlar yüklenemedi.'));
          }
          final tours = snapshot.data!.tours;
          final peek = snapshot.data!.peek;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.pageHorizontalMargin,
              20,
              AppConstants.pageHorizontalMargin,
              32,
            ),
            children: [
              _CreatorToursHero(openTourCount: tours.length),
              const SizedBox(height: 16),
              if (peek.studentProfilePreviewLine != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TurIzimSurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Üniversite öğrencisi içerik üretici profiliniz',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: TurIzimPalette.deepNavy,
                                  ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          peek.creatorDisplayName,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: TurIzimPalette.deepNavy,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          peek.studentProfilePreviewLine!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                height: 1.4,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 28),
                const TurIzimSectionHeader(
                  overline: 'Öğrenci içerik üreticisi fırsatları',
                  title: 'İlanlar (yayımda)',
                  subtitle:
                      'Her ilan için çıkış şehri ve tur rotası kartta özetlenir; '
                          'liste ilan kutusunda detay için dokunun.',
                ),
              const SizedBox(height: 14),
              ...tours.map(
                (tour) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _CreatorOpportunityCard(
                    tour: tour,
                    onTap: () => context.push(AppRoutes.creatorTour(tour.id)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CreatorToursHero extends StatelessWidget {
  const _CreatorToursHero({required this.openTourCount});

  final int openTourCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          TurIzimDesignTokens.radiusExtraLarge,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TurIzimPalette.sandCream.withValues(alpha: 0.94),
            TurIzimPalette.softSkyBlue.withValues(alpha: 0.72),
            TurIzimPalette.softLavender.withValues(alpha: 0.88),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
        boxShadow: TurIzimDesignTokens.premiumShadow(),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -34,
            top: -30,
            child: _DecorativeCircle(
              size: 136,
              color: TurIzimPalette.royalIndigo.withValues(alpha: 0.10),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -34,
            child: _DecorativeCircle(
              size: 108,
              color: TurIzimPalette.softCoral.withValues(alpha: 0.13),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(TurIzimDesignTokens.cardPaddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TurIzimStatusPill(
                  label: 'Öğrenci içerik üreticisi fırsatı',
                  tone: TurIzimStatusTone.accent,
                  icon: Icons.school_outlined,
                ),
                const SizedBox(height: 16),
                Text(
                  'Üniversite içerik üreticisi fırsat panosu',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: TurIzimPalette.deepNavy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Üniversite öğrencisi içerik üreticileri için yerel acentelerin yayınladığı ulaşım dahil tur fırsatlarını inceleyin. Başvuru ve seçim süreci manuel ilerler.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: TurIzimPalette.deepNavy.withValues(alpha: 0.70),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _HeroChip(
                      icon: Icons.explore_outlined,
                      label: '$openTourCount yayındaki ilan',
                    ),
                    const _HeroChip(
                      icon: Icons.how_to_vote_outlined,
                      label: 'Manuel acente seçimi',
                    ),
                    const _HeroChip(
                      icon: Icons.link_rounded,
                      label: 'İçerik URL ile teslim',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CreatorOpportunityCard extends StatelessWidget {
  const _CreatorOpportunityCard({required this.tour, required this.onTap});

  final TourSummary tour;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TurIzimSurfaceCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TourVisualHeader(
            tour: tour,
            height: 138,
            borderRadius: BorderRadius.zero,
          ),
          Padding(
            padding: const EdgeInsets.all(TurIzimDesignTokens.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tour.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: TurIzimPalette.deepNavy,
                    fontWeight: FontWeight.w800,
                    height: 1.22,
                  ),
                ),
                if (tour.agencyLegalName != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Acente: ${tour.agencyLegalName}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
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
                    if (tour.transportationIncluded)
                      const TurIzimStatusPill(
                        label: 'Ulaşım dahil',
                        tone: TurIzimStatusTone.success,
                        icon: Icons.directions_bus_filled_outlined,
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                _IconTextLine(
                  icon: Icons.location_city_outlined,
                  text: 'Çıkış şehri: ${tour.departureCity}',
                ),
                const SizedBox(height: 6),
                _IconTextLine(
                  icon: Icons.route_rounded,
                  text: 'Tur rotası: ${tourRouteOverviewLineTurkish(tour)}',
                ),
                const SizedBox(height: 8),
                _IconTextLine(
                  icon: Icons.calendar_month_outlined,
                  text:
                      '${formatTourCalendarDate(tour.startsAt)} – ${formatTourCalendarDate(tour.endsAt)}',
                ),
                const SizedBox(height: 8),
                _IconTextLine(
                  icon: Icons.event_seat_outlined,
                  text:
                      '${tour.seatsOffered} koltuk · Üretici kotası: ${tour.remainingCreatorSlots}/${tour.creatorQuota}',
                ),
                const SizedBox(height: 16),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: TurIzimPalette.softLavender.withValues(alpha: 0.54),
                    borderRadius: BorderRadius.circular(
                      TurIzimDesignTokens.radiusMedium,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        _PriceRow(
                          label: 'Normal satış değeri',
                          value: formatTurkishLiraAmount(
                            tour.normalSalesPrice,
                            currencyCode: tour.currency,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _PriceRow(
                          label: 'Beklenen depozito',
                          value: formatTurkishLiraAmount(
                            tour.expectedDepositAmount,
                            currencyCode: tour.currency,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (tour.tourScope == TourScope.international) ...[
                  const SizedBox(height: 12),
                  _InternationalGateNote(tour: tour),
                ],
                const SizedBox(height: 16),
                TurIzimPrimaryButton(
                  label: 'Detayları Gör',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: onTap,
                ),
              ],
            ),
          ),
        ],
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

class _InternationalGateNote extends StatelessWidget {
  const _InternationalGateNote({required this.tour});

  final TourSummary tour;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final passport = tour.requiresPassport
        ? 'Pasaport: ${passportTypeLabelTurkish(tour.minimumPassportType)}'
        : 'Pasaport şartı beyanı yok';
    final visa = tour.requiresVisa
        ? 'Vize: ${tour.visaRequirementText ?? 'Acente beyanı'}'
        : 'Vize şartı beyanı yok';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: TurIzimPalette.softSkyBlue.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(TurIzimDesignTokens.radiusMedium),
        border: Border.all(
          color: TurIzimPalette.royalIndigo.withValues(alpha: 0.10),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pasaport/vize ayrı uygunluk kapısıdır',
              style: theme.textTheme.labelLarge?.copyWith(
                color: TurIzimPalette.deepNavy,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$passport · $visa',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.64),
        borderRadius: BorderRadius.circular(TurIzimDesignTokens.radiusPill),
        border: Border.all(color: Colors.white.withValues(alpha: 0.70)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: TurIzimPalette.royalIndigo),
            const SizedBox(width: 7),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: TurIzimPalette.deepNavy,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: TurIzimPalette.deepNavy,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _IconTextLine extends StatelessWidget {
  const _IconTextLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 18, color: TurIzimPalette.royalIndigo),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  const _DecorativeCircle({required this.size, required this.color});

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
