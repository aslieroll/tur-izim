import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tur_izim/app/router.dart';
import 'package:tur_izim/app/tur_izim_scope.dart';
import 'package:tur_izim/core/constants/app_constants.dart';
import 'package:tur_izim/core/di/tur_izim_dependencies.dart';
import 'package:tur_izim/shared/models/tour_summary.dart';
import 'package:tur_izim/shared/presentation/status_label_turkish.dart';
import 'package:tur_izim/shared/widgets/status_badge.dart';
import 'package:tur_izim/shared/widgets/tour_pricing_info_lines.dart';
import 'package:tur_izim/shared/widgets/tour_travel_scope_summary_lines.dart';
import 'package:tur_izim/shared/widgets/tur_izim_section_header.dart';
import 'package:tur_izim/shared/widgets/tur_izim_surface_card.dart';

String _formatTourDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

class AgencyBoardScreen extends StatelessWidget {
  const AgencyBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deps = TurIzimDependencies.of(context);
    final session = TurIzimScope.of(context);

    final agencyId = session.activeAgencyId!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Operasyon özeti'),
        actions: [
          TextButton(
            onPressed: () async {
              await session.clearSession();
              if (context.mounted) context.go(AppRoutes.welcome);
            },
            child: const Text('Çıkış'),
          ),
        ],
      ),
      body: FutureBuilder<(int, List<TourSummary>)>(
        future: () async {
          final awaiting = await deps.agencyDashboard.countAwaitingApplicants(
            agencyId,
          );
          final tours = await deps.agencyDashboard.featuredTours(agencyId);
          return (awaiting, tours);
        }(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final awaiting = snap.data!.$1;
          final tours = snap.data!.$2;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.pageHorizontalMargin,
              16,
              AppConstants.pageHorizontalMargin,
              24,
            ),
            children: [
              TurIzimSurfaceCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bekleyen başvurular',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      awaiting.toString(),
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppConstants.sectionGapLarge / 2),
              TurIzimSectionHeader(
                title: 'Kayıtlı ilanlar (${tours.length})',
                subtitle: 'Başvuranlar için karta dokunun.',
              ),
              const SizedBox(height: 12),
              ...tours.map((t) {
                final theme = Theme.of(context);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TurIzimSurfaceCard(
                    onTap: () => context.push(AppRoutes.agencyApplicants(t.id)),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.title, style: theme.textTheme.titleMedium),
                        const SizedBox(height: 6),
                        Text(
                          '${t.departureCity} → '
                          '${destinationClusterLabelTurkish(t.destinationCluster)}',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatTourDate(t.startsAt)} – '
                          '${_formatTourDate(t.endsAt)} · '
                          '${t.seatsOffered} koltuk',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 6),
                        TourTravelScopeSummaryLines(tour: t, dense: true),
                        const SizedBox(height: 6),
                        Text(
                          'Bekleyen başvuru: ${t.pendingApplicationCount} · '
                          'Atanan: ${t.acceptedAssignmentCount}/${t.creatorQuota}',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 6),
                        TourPricingInfoLines(tour: t, dense: true),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: StatusBadge(
                            label: tourStatusLabelTurkish(t.status),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
