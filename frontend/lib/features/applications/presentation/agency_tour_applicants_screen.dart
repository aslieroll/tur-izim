import 'package:flutter/material.dart';

import 'package:tur_izim/app/tur_izim_scope.dart';
import 'package:tur_izim/core/di/tur_izim_dependencies.dart';
import 'package:tur_izim/shared/models/application_status.dart';
import 'package:tur_izim/shared/models/assignment_summary.dart';
import 'package:tur_izim/shared/models/rated_application.dart';
import 'package:tur_izim/shared/models/tour_detail.dart';
import 'package:tur_izim/shared/presentation/creator_profile_preview_bullets.dart';
import 'package:tur_izim/shared/presentation/status_label_turkish.dart';
import 'package:tur_izim/shared/widgets/applicant_sort_disclaimer.dart';
import 'package:tur_izim/shared/widgets/status_badge.dart';
import 'package:tur_izim/shared/widgets/suitability_score_card.dart';
import 'package:tur_izim/shared/widgets/tour_pricing_info_lines.dart';
import 'package:tur_izim/shared/widgets/tour_travel_scope_summary_lines.dart';

typedef _ApplicantsPayload = ({
  TourMeta meta,
  TourDetail? tour,
  List<RatedApplication> rows,
  List<AssignmentSummary> assignments,
});

/// Aşama 2.5–2.6 — ilan başına başvuran listesi; acente tek tek seçim yapar (mock).
class AgencyTourApplicantsScreen extends StatefulWidget {
  const AgencyTourApplicantsScreen({required this.tourId, super.key});

  final String tourId;

  @override
  State<AgencyTourApplicantsScreen> createState() =>
      _AgencyTourApplicantsScreenState();
}

class _AgencyTourApplicantsScreenState
    extends State<AgencyTourApplicantsScreen> {
  Future<_ApplicantsPayload>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<_ApplicantsPayload> _load() async {
    final deps = TurIzimDependencies.of(context);
    final session = TurIzimScope.of(context);
    final agencyId = session.activeAgencyId!;

    final tour = await deps.tours.fetchTourDetail(widget.tourId);
    final meta = tour == null
        ? TourMeta(quota: 0, remaining: 0, accepted: 0)
        : TourMeta(
            quota: tour.creatorQuota,
            remaining: tour.remainingCreatorSlots,
            accepted: tour.acceptedAssignmentCount,
          );

    final rows = tour == null
        ? const <RatedApplication>[]
        : await deps.applications.listRatedApplicantsForTour(
            actingAgencyId: agencyId,
            tourId: widget.tourId,
          );

    final assignments = tour == null
        ? const <AssignmentSummary>[]
        : await deps.assignments.listByTourForAgency(
            agencyId: agencyId,
            tourId: widget.tourId,
          );

    return (meta: meta, tour: tour, rows: rows, assignments: assignments);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Başvuranlar')),
      body: FutureBuilder<_ApplicantsPayload>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting ||
              snap.data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snap.data!;
          final meta = data.meta;
          final tourTitle = data.tour?.title ?? 'Bu ilan';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tourTitle, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Kota ${meta.quota} · Müsait seçim: ${meta.remaining} · '
                      'Atanan: ${meta.accepted}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (data.tour != null) ...[
                      const SizedBox(height: 10),
                      TourPricingInfoLines(tour: data.tour!, dense: true),
                      const SizedBox(height: 8),
                      TourTravelScopeSummaryLines(
                        tour: data.tour!,
                        dense: true,
                      ),
                    ],
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: ApplicantSortDisclaimer(),
              ),
              if (data.assignments.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Atamalar (salt okunur)',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      ...data.assignments.map((a) {
                        final depositLabel = a.depositStatus != null
                            ? mockDepositStatusLabelTurkish(a.depositStatus!)
                            : '—';
                        return Card.outlined(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            dense: true,
                            title: Text(
                              a.tourTitle ?? a.id,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              'Atama durumu: '
                              '${assignmentStatusLabelTurkish(a.status)} · '
                              'Mock depozito: $depositLabel',
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              Expanded(
                child: data.rows.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 56,
                                color: theme.colorScheme.outline,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Bu ilana henüz başvuru yok.',
                                style: theme.textTheme.titleMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Yeni başvurular geldiğinde burada '
                                'önizleme olarak listelenir (mock).',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: data.rows.length,
                        itemBuilder: (context, index) {
                          final row = data.rows[index];
                          final bullets = creatorProfileMockPreviewBullets(
                            row.creator,
                          );
                          final selectHint = agencyApplicantSelectHint(
                            status: row.summary.status,
                            remaining: meta.remaining,
                          );

                          return Card.outlined(
                            margin: const EdgeInsets.only(bottom: 14),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          row.creator.displayName,
                                          style: theme.textTheme.titleMedium,
                                        ),
                                      ),
                                      StatusBadge(
                                        label: applicationStatusLabelTurkish(
                                          row.summary.status,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'İlan: $tourTitle',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Aday Uygunluk Endeksi: '
                                    '${row.scores.aue.round()}/100',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (row.summary.message != null &&
                                      row.summary.message!.trim().isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        'Başvuru notu: ${row.summary.message}',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ),
                                  if (bullets.isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    Text(
                                      'Profil özeti (mock)',
                                      style: theme.textTheme.labelLarge,
                                    ),
                                    const SizedBox(height: 4),
                                    ...bullets.map(
                                      (b) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 2,
                                        ),
                                        child: Text(
                                          '· $b',
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  SuitabilityScoreCard(scores: row.scores),
                                  const SizedBox(height: 14),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                      onPressed: null,
                                      child: const Text('Seçim bu dilimde kapalı'),
                                    ),
                                  ),
                                  if (selectHint != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        selectHint,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              SafeArea(
                child: Material(
                  elevation: 2,
                  color: theme.colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      meta.remaining <= 0
                          ? 'Bu tur için seçim kotası doldu; yeni seçim '
                                'yapılamaz.'
                          : 'Kota içinde kalmak şartıyla, seçilecek başvuru için '
                                'kart üzerindeki «Bu başvuruyu seç» düğmesini '
                                'kullanın.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
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

/// Kart altı kısa bilgi (iş kuralı mağazada).
String? agencyApplicantSelectHint({
  required ApplicationStatus status,
  required int remaining,
}) {
  if (remaining <= 0) {
    return 'Bu tur için seçim kotası dolu.';
  }
  if (status != ApplicationStatus.pendingReview) {
    return switch (status) {
      ApplicationStatus.accepted => 'Bu başvuru seçildi.',
      ApplicationStatus.rejected => 'Bu başvuru reddedildi.',
      ApplicationStatus.withdrawn => 'Başvuru geri çekildi.',
      ApplicationStatus.pendingReview => null,
    };
  }
  return null;
}

class TourMeta {
  TourMeta({
    required this.quota,
    required this.remaining,
    required this.accepted,
  });

  final int quota;
  final int remaining;
  final int accepted;
}
