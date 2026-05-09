import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tur_izim/app/router.dart';
import 'package:tur_izim/app/tur_izim_scope.dart';
import 'package:tur_izim/core/di/tur_izim_dependencies.dart';
import 'package:tur_izim/shared/models/tour_detail.dart';
import 'package:tur_izim/shared/models/tour_scope.dart';
import 'package:tur_izim/shared/presentation/status_label_turkish.dart';
import 'package:tur_izim/shared/presentation/tour_display_format.dart';
import 'package:tur_izim/shared/presentation/tour_requirement_labels_turkish.dart';
import 'package:tur_izim/shared/widgets/international_mandatory_requirements_card.dart';
import 'package:tur_izim/shared/widgets/publication_commitment_info_card.dart';
import 'package:tur_izim/shared/widgets/status_badge.dart';
import 'package:tur_izim/shared/widgets/tour_pricing_info_lines.dart';

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
    final theme = Theme.of(context);
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

          final agencyLine =
              tour.agencyLegalName ?? 'Acente adı bu önizlemede yok';
          final canOpenForm =
              tour.isOpenForApplications && !applied && eligible;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tour.title, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  'Acente: $agencyLine',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    StatusBadge(label: tourStatusLabelTurkish(tour.status)),
                    StatusBadge(
                      label:
                          'Ulaşım '
                          '${tour.transportationIncluded ? "dahil" : "hariç"}',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Güzergâh', style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  '${tour.departureCity} → '
                  '${destinationClusterLabelTurkish(tour.destinationCluster)}',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 12),
                Text('Tarih', style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  '${formatTourCalendarDate(tour.startsAt)} – '
                  '${formatTourCalendarDate(tour.endsAt)}',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 12),
                Text('Kapasite', style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  '${tour.seatsOffered} koltuk · '
                  'Üretici kotası: ${tour.remainingCreatorSlots}/'
                  '${tour.creatorQuota}',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Text('Fiyat bilgisi', style: theme.textTheme.titleMedium),
                const SizedBox(height: 6),
                TourPricingInfoLines(tour: tour),
                const SizedBox(height: 12),
                InternationalMandatoryRequirementsCard(tour: tour),
                const SizedBox(height: 16),
                Text('Açıklama', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(tour.description, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 16),
                Text('İçerik beklentileri', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
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
                          (r) => Chip(
                            label: Text(tourRequirementShortLabelTurkish(r)),
                          ),
                        )
                        .toList(),
                  ),
                const SizedBox(height: 20),
                Text(
                  'Başvuru öncesi bilgilendirme',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                const PublicationCommitmentInfoCard(),
                const SizedBox(height: 20),
                if (!eligible && tour.tourScope == TourScope.international)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Bu yurt dışı turu için pasaport/vize uygunluğunuz '
                      'bulunmuyor.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                if (!tour.isOpenForApplications && !applied)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Bu tur için başvurular kota veya iş kuralı nedeniyle kapalı.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                if (applied)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Bu ilana zaten başvurdunuz; tekrar gönderilemez.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.tertiary,
                      ),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: canOpenForm
                        ? () => context.push(
                            AppRoutes.creatorApply(widget.tourId),
                          )
                        : null,
                    child: const Text('Başvuru formuna geç'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
