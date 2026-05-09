import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tur_izim/app/router.dart';
import 'package:tur_izim/app/tur_izim_scope.dart';
import 'package:tur_izim/core/constants/app_constants.dart';
import 'package:tur_izim/core/di/tur_izim_dependencies.dart';
import 'package:tur_izim/shared/models/tour_summary.dart';
import 'package:tur_izim/shared/presentation/status_label_turkish.dart';
import 'package:tur_izim/shared/presentation/tour_display_format.dart';
import 'package:tur_izim/shared/widgets/status_badge.dart';
import 'package:tur_izim/shared/widgets/tour_pricing_info_lines.dart';
import 'package:tur_izim/shared/widgets/tur_izim_section_header.dart';
import 'package:tur_izim/shared/widgets/tur_izim_surface_card.dart';

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
      body: FutureBuilder<List<TourSummary>>(
        future: deps.tours.fetchPublishedToursForCreator(
          session.activeCreatorId!,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('Turlar yüklenemedi.'));
          }
          final tours = snapshot.data!;
          final theme = Theme.of(context);

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.pageHorizontalMargin,
              16,
              AppConstants.pageHorizontalMargin,
              24,
            ),
            children: [
              const TurIzimSectionHeader(
                title: 'İlanlar (yayımda)',
                subtitle:
                    'Ulaşım dahil pilot ilanlar; karta dokunarak detaya gidebilirsiniz.',
              ),
              SizedBox(height: AppConstants.sectionGapLarge / 2),
              ...tours.map((tour) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TurIzimSurfaceCard(
                    onTap: () => context.push(AppRoutes.creatorTour(tour.id)),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tour.title, style: theme.textTheme.titleMedium),
                        const SizedBox(height: 6),
                        Text(
                          '${tour.departureCity} → '
                          '${destinationClusterLabelTurkish(tour.destinationCluster)}',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${formatTourCalendarDate(tour.startsAt)} – '
                          '${formatTourCalendarDate(tour.endsAt)} · '
                          '${tour.seatsOffered} koltuk · '
                          'Üretici kotası: ${tour.remainingCreatorSlots}/'
                          '${tour.creatorQuota}',
                          style: theme.textTheme.bodySmall,
                        ),
                        if (tour.agencyLegalName != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Acente: ${tour.agencyLegalName}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        TourPricingInfoLines(tour: tour),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: StatusBadge(
                            label: tourStatusLabelTurkish(tour.status),
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
