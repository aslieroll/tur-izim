import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tur_izim/app/router.dart';
import 'package:tur_izim/app/tur_izim_scope.dart';
import 'package:tur_izim/core/constants/app_constants.dart';
import 'package:tur_izim/core/di/tur_izim_dependencies.dart';
import 'package:tur_izim/core/errors/user_error_message.dart';
import 'package:tur_izim/features/agency_dashboard/domain/agency_board_snapshot.dart';
import 'package:tur_izim/features/agency_dashboard/presentation/agency_pro_package_card.dart';
import 'package:tur_izim/features/billing/domain/agency_subscription.dart';
import 'package:tur_izim/shared/models/tour_scope.dart';
import 'package:tur_izim/shared/models/tour_summary.dart';
import 'package:tur_izim/shared/models/tour_status.dart';
import 'package:tur_izim/shared/presentation/status_label_turkish.dart';
import 'package:tur_izim/shared/presentation/travel_eligibility_labels_turkish.dart';
import 'package:tur_izim/shared/presentation/tour_display_format.dart';
import 'package:tur_izim/shared/presentation/turkish_lira_format.dart';
import 'package:tur_izim/shared/theme/tur_izim_design_tokens.dart';
import 'package:tur_izim/shared/widgets/tur_izim_metric_card.dart';
import 'package:tur_izim/shared/widgets/tur_izim_section_header.dart';
import 'package:tur_izim/shared/widgets/tur_izim_status_pill.dart';
import 'package:tur_izim/shared/widgets/tur_izim_surface_card.dart';
import 'package:tur_izim/shared/widgets/tour_visual_header.dart';

String _formatTourDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

class AgencyBoardScreen extends StatefulWidget {
  const AgencyBoardScreen({super.key});

  @override
  State<AgencyBoardScreen> createState() => _AgencyBoardScreenState();
}

typedef _BoardData = (AgencyBoardSnapshot, AgencySubscription);

class _AgencyBoardScreenState extends State<AgencyBoardScreen> {
  Future<_BoardData>? _loadFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFuture ??= _createLoadFuture();
  }

  Future<_BoardData> _createLoadFuture() async {
    final deps = TurIzimDependencies.of(context);
    final session = TurIzimScope.of(context);
    final agencyId = session.activeAgencyId!;
    final results = await Future.wait([
      deps.agencyDashboard.loadAgencyBoard(agencyId),
      deps.billing.getSubscription(agencyId),
    ]);
    return (results[0] as AgencyBoardSnapshot, results[1] as AgencySubscription);
  }

  void _retry() {
    setState(() {
      _loadFuture = _createLoadFuture();
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = TurIzimScope.of(context);

    return Scaffold(
      backgroundColor: TurIzimPalette.warmWhite,
      appBar: AppBar(
        title: Text(
          'Operasyon özeti',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: TurIzimPalette.deepNavy,
                fontWeight: FontWeight.w800,
              ),
        ),
        backgroundColor: TurIzimPalette.warmWhite,
        foregroundColor: TurIzimPalette.deepNavy,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: TurIzimPalette.royalIndigo,
            ),
            onPressed: () async {
              await session.clearSession();
              if (context.mounted) context.go(AppRoutes.welcome);
            },
            child: const Text('Çıkış'),
          ),
        ],
      ),
      body: FutureBuilder<_BoardData>(
        future: _loadFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.pageHorizontalMargin),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      userFacingErrorMessage(snap.error),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: TurIzimPalette.deepNavy.withValues(alpha: 0.85),
                          ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _retry,
                      child: const Text('Yeniden dene'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final (board, subscription) = snap.data!;
          final tours = board.tours;
          final awaiting = board.pendingApplicantCount;
          final activePublishedCount = tours
              .where(
                (tour) =>
                    tour.status == TourStatus.published ||
                    tour.status == TourStatus.applicationClosed ||
                    tour.status == TourStatus.assigned,
              )
              .length;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.pageHorizontalMargin,
              20,
              AppConstants.pageHorizontalMargin,
              32,
            ),
            children: [
              _AgencySummaryHero(
                activePublishedCount: activePublishedCount,
                registeredTourCount: tours.length,
                pendingApplicantCount: awaiting,
              ),
              if (!subscription.isPaid) ...[
                const SizedBox(height: 20),
                const _SubscriptionRequiredBanner(),
                SubscriptionPlansSection(subscription: subscription),
              ],
              const SizedBox(height: 28),
              TurIzimSectionHeader(
                overline: 'Acente operasyonu',
                title: 'Kayıtlı ilanlar',
                subtitle:
                    'Öğrenci içerik üreticisi başvurularını görüntülemek ve manuel '
                        'atanım sürecini yönetmek için karta dokunun (otomatik atama '
                        'yok).',
              ),
              const SizedBox(height: 14),
              ...tours.map(
                (tour) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _AgencyTourCard(
                    tour: tour,
                    onTap: () =>
                        context.push(AppRoutes.agencyApplicants(tour.id)),
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

class _SubscriptionRequiredBanner extends StatelessWidget {
  const _SubscriptionRequiredBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: TurIzimPalette.warningAmber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(TurIzimDesignTokens.radiusMedium),
        border: Border.all(
          color: TurIzimPalette.warningAmber.withValues(alpha: 0.35),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 20,
              color: TurIzimPalette.warningAmber,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Bu özellik Agency Pro aboneliği gerektirir. '
                'Başvuru yönetimi ve AI Eşleşme Asistanı için '
                'aşağıdaki paketi edinin.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: TurIzimPalette.deepNavy.withValues(alpha: 0.80),
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AgencySummaryHero extends StatelessWidget {
  const _AgencySummaryHero({
    required this.activePublishedCount,
    required this.registeredTourCount,
    required this.pendingApplicantCount,
  });

  final int activePublishedCount;
  final int registeredTourCount;
  final int pendingApplicantCount;

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
            TurIzimPalette.softSkyBlue.withValues(alpha: 0.90),
            TurIzimPalette.softLavender.withValues(alpha: 0.92),
            Colors.white.withValues(alpha: 0.96),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.70)),
        boxShadow: TurIzimDesignTokens.premiumShadow(),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -36,
            top: -28,
            child: _DecorativeOrb(
              color: TurIzimPalette.royalIndigo.withValues(alpha: 0.10),
              size: 132,
            ),
          ),
          Positioned(
            left: -28,
            bottom: -32,
            child: _DecorativeOrb(
              color: TurIzimPalette.softCoral.withValues(alpha: 0.13),
              size: 100,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(TurIzimDesignTokens.cardPaddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TurIzimStatusPill(
                  label: 'Operasyon Paneli',
                  tone: TurIzimStatusTone.accent,
                  icon: Icons.auto_awesome_rounded,
                ),
                const SizedBox(height: 16),
                Text(
                  'Operasyon özeti',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: TurIzimPalette.deepNavy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Yayındaki turlarınızı, bekleyen başvuruları ve manuel seçim sürecini tek ekrandan takip edin.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: TurIzimPalette.deepNavy.withValues(alpha: 0.70),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 22),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final useColumns = constraints.maxWidth >= 680;
                    final metricWidth = useColumns
                        ? (constraints.maxWidth - 24) / 3
                        : double.infinity;

                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: metricWidth,
                          child: TurIzimMetricCard(
                            label: 'Yayındaki / aktif ilan',
                            value: activePublishedCount.toString(),
                            icon: Icons.explore_outlined,
                            supportingText: 'Başvuru veya atama sürecinde',
                          ),
                        ),
                        SizedBox(
                          width: metricWidth,
                          child: TurIzimMetricCard(
                            label: 'Kayıtlı ilan',
                            value: registeredTourCount.toString(),
                            icon: Icons.inventory_2_outlined,
                            supportingText: 'Tüm acente ilanları',
                          ),
                        ),
                        SizedBox(
                          width: metricWidth,
                          child: TurIzimMetricCard(
                            label: 'Bekleyen başvuru',
                            value: pendingApplicantCount.toString(),
                            icon: Icons.group_add_outlined,
                            supportingText: 'Acentenin manuel incelemesi için',
                            accentColor: TurIzimPalette.softCoral,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AgencyTourCard extends StatelessWidget {
  const _AgencyTourCard({required this.tour, required this.onTap});

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
            height: 112,
            borderRadius: BorderRadius.zero,
            showLabel: true,
            showTitleOverlay: false,
          ),
          Container(
            padding: const EdgeInsets.all(TurIzimDesignTokens.cardPadding),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  TurIzimPalette.sandCream.withValues(alpha: 0.56),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
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
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  tour.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: TurIzimPalette.deepNavy,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 10),
                _IconTextLine(
                  icon: Icons.location_city_outlined,
                  text: 'Çıkış şehri: ${tour.departureCity}',
                ),
                const SizedBox(height: 6),
                _IconTextLine(
                  icon: Icons.route_rounded,
                  text: 'Tur rotası: ${tourRouteOverviewLineTurkish(tour)}',
                ),
                const SizedBox(height: 6),
                _IconTextLine(
                  icon: Icons.calendar_month_outlined,
                  text:
                      '${_formatTourDate(tour.startsAt)} – ${_formatTourDate(tour.endsAt)}',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(TurIzimDesignTokens.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _TourStatChip(
                      label: 'Koltuk',
                      value: tour.seatsOffered.toString(),
                      icon: Icons.event_seat_outlined,
                    ),
                    _TourStatChip(
                      label: 'Bekleyen başvuru',
                      value: tour.pendingApplicationCount.toString(),
                      icon: Icons.hourglass_top_rounded,
                    ),
                    _TourStatChip(
                      label: 'Atanan',
                      value:
                          '${tour.acceptedAssignmentCount}/${tour.creatorQuota}',
                      icon: Icons.assignment_turned_in_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: TurIzimPalette.softLavender.withValues(alpha: 0.52),
                    borderRadius: BorderRadius.circular(
                      TurIzimDesignTokens.radiusMedium,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        _PriceRow(
                          label: 'Normal satış fiyatı',
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
                  Text(
                    'Pasaport/vize uygunluğu ayrı başvuru kapısıdır; Aday Uygunluk Endeksi bileşeni değildir.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Başvuruları incele',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: TurIzimPalette.royalIndigo,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: TurIzimPalette.royalIndigo,
                      size: 20,
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

class _TourStatChip extends StatelessWidget {
  const _TourStatChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(TurIzimDesignTokens.radiusMedium),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17, color: TurIzimPalette.royalIndigo),
            const SizedBox(width: 8),
            Text(
              '$label: ',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
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

class _DecorativeOrb extends StatelessWidget {
  const _DecorativeOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
