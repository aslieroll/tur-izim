import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tur_izim/app/router.dart';
import 'package:tur_izim/app/tur_izim_scope.dart';
import 'package:tur_izim/core/di/tur_izim_dependencies.dart';
import 'package:tur_izim/shared/models/tour_summary.dart';
import 'package:tur_izim/shared/models/tour_scope.dart';
import 'package:tur_izim/shared/presentation/status_label_turkish.dart';
import 'package:tur_izim/shared/presentation/travel_eligibility_labels_turkish.dart';
import 'package:tur_izim/shared/theme/tur_izim_design_tokens.dart';
import 'package:tur_izim/shared/widgets/tour_pricing_info_lines.dart';
import 'package:tur_izim/shared/widgets/tour_travel_scope_summary_lines.dart';
import 'package:tur_izim/shared/presentation/tour_display_format.dart';
import 'package:tur_izim/shared/widgets/tour_visual_header.dart';
import 'package:tur_izim/shared/widgets/tur_izim_info_banner.dart';
import 'package:tur_izim/shared/widgets/tur_izim_surface_card.dart';
import 'package:tur_izim/shared/widgets/tur_izim_status_pill.dart';

class AgencyToursScreen extends StatelessWidget {
  const AgencyToursScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deps = TurIzimDependencies.of(context);
    final session = TurIzimScope.of(context);
    final agencyId = session.activeAgencyId!;

    return Scaffold(
      backgroundColor: TurIzimPalette.warmWhite,
      appBar: AppBar(
        backgroundColor: TurIzimPalette.warmWhite,
        foregroundColor: TurIzimPalette.deepNavy,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'İlanlarım',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: TurIzimPalette.deepNavy,
                fontWeight: FontWeight.w700,
              ),
        ),
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
      body: FutureBuilder<List<TourSummary>>(
        future: deps.tours.fetchAgencyTours(agencyId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final rows = snapshot.data ?? const [];
          if (rows.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: TurIzimSurfaceCard(
                  child: Text(
                    'Kayıtlı tur yok.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: TurIzimPalette.deepNavy,
                        ),
                  ),
                ),
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final inset = constraints.maxWidth >
                      TurIzimDesignTokens.maxReadableWidth + 48
                  ? (constraints.maxWidth -
                          TurIzimDesignTokens.maxReadableWidth) /
                      2
                  : TurIzimDesignTokens.pageMargin;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      inset,
                      TurIzimDesignTokens.stackSmall,
                      inset,
                      0,
                    ),
                    child: const TurIzimInfoBanner(
                      tone: TurIzimStatusTone.info,
                      icon: Icons.location_city_rounded,
                      title: 'Şehir ve tur rotası',
                      message:
                          'Yeni ilanda çıkış şehri ile tur rotası değerleri '
                              'acentenin kayıt ve ilan formunda manuel girilir; '
                              'MVP’de otomatik doğrulama yapılmaz.',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        inset,
                        0,
                        inset,
                        TurIzimDesignTokens.stackLarge,
                      ),
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemCount: rows.length,
                      itemBuilder: (ctx, idx) {
                        final t = rows[idx];
                        return TurIzimSurfaceCard(
                          padding: EdgeInsets.zero,
                          onTap: () =>
                              context.push(AppRoutes.agencyApplicants(t.id)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TourVisualHeader(
                                tour: t,
                                height: 100,
                                showLabel: true,
                                showTitleOverlay: false,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(
                                    TurIzimDesignTokens.radiusLarge,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(
                                  TurIzimDesignTokens.cardPadding,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 8,
                                      children: [
                                        TurIzimStatusPill(
                                          icon: Icons.campaign_rounded,
                                          label: tourStatusLabelTurkish(
                                            t.status,
                                          ),
                                        ),
                                        TurIzimStatusPill(
                                          tone:
                                              t.tourScope ==
                                                      TourScope.international
                                                  ? TurIzimStatusTone.warning
                                                  : TurIzimStatusTone.info,
                                          icon:
                                              t.tourScope ==
                                                      TourScope.international
                                                  ? Icons.public_rounded
                                                  : Icons.flag_rounded,
                                          label: tourScopeLabelTurkish(
                                            t.tourScope,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.location_city_outlined,
                                          size: 17,
                                          color: TurIzimPalette.deepNavy
                                              .withValues(alpha: 0.72),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            'Çıkış şehri: ${t.departureCity}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.alt_route_rounded,
                                          size: 17,
                                          color: TurIzimPalette.deepNavy
                                              .withValues(alpha: 0.72),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            'Tur rotası: ${tourRouteOverviewLineTurkish(t)}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(height: 1.4),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      t.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: TurIzimPalette.deepNavy,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    TourTravelScopeSummaryLines(
                                      tour: t,
                                      dense: true,
                                    ),
                                    const SizedBox(height: 8),
                                    TourPricingInfoLines(tour: t, dense: true),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Bekleyen öğrenci içerik üreticisi '
                                      'başvurusu: ${t.pendingApplicationCount}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                            height: 1.35,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
