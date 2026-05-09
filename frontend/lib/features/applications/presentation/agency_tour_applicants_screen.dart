import 'package:flutter/material.dart';

import 'package:tur_izim/app/tur_izim_scope.dart';
import 'package:tur_izim/core/di/tur_izim_dependencies.dart';
import 'package:tur_izim/features/applications/presentation/agency_rated_applicant_detail_screen.dart';
import 'package:tur_izim/features/applications/presentation/agency_review_content_delivery_screen.dart';
import 'package:tur_izim/features/publications/presentation/agency_review_publication_screen.dart';
import 'package:tur_izim/shared/models/application_status.dart';
import 'package:tur_izim/shared/models/assignment_summary.dart';
import 'package:tur_izim/shared/models/assignment_status.dart';
import 'package:tur_izim/shared/models/rated_application.dart';
import 'package:tur_izim/shared/models/student_verification_status.dart';
import 'package:tur_izim/shared/models/tour_detail.dart';
import 'package:tur_izim/shared/presentation/creator_profile_preview_bullets.dart';
import 'package:tur_izim/shared/presentation/status_label_turkish.dart';
import 'package:tur_izim/shared/theme/tur_izim_design_tokens.dart';
import 'package:tur_izim/shared/widgets/applicant_sort_disclaimer.dart';
import 'package:tur_izim/shared/widgets/suitability_score_card.dart';
import 'package:tur_izim/shared/widgets/tour_pricing_info_lines.dart';
import 'package:tur_izim/shared/widgets/tour_travel_scope_summary_lines.dart';
import 'package:tur_izim/shared/widgets/tur_izim_info_banner.dart';
import 'package:tur_izim/shared/widgets/tur_izim_primary_button.dart';
import 'package:tur_izim/shared/widgets/tur_izim_secondary_button.dart';
import 'package:tur_izim/shared/widgets/tur_izim_surface_card.dart';
import 'package:tur_izim/shared/widgets/tur_izim_status_pill.dart';

typedef _ApplicantsPayload = ({
  TourMeta meta,
  TourDetail? tour,
  List<RatedApplication> rows,
  List<AssignmentSummary> assignments,
});

/// Başvuran öğrenci içerik üreticileri — seçim tamamen acente elindedir (mock UI).
class AgencyTourApplicantsScreen extends StatefulWidget {
  const AgencyTourApplicantsScreen({required this.tourId, super.key});

  final String tourId;

  @override
  State<AgencyTourApplicantsScreen> createState() =>
      _AgencyTourApplicantsScreenState();
}

class _AgencyTourApplicantsScreenState extends State<AgencyTourApplicantsScreen> {
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

  Future<void> _refreshAfterNavigate(Future<Object?> nav) async {
    await nav;
    if (!mounted) return;
    setState(() => _future = _load());
    await _future;
  }

  Future<void> _selectApplicant(String applicationId) async {
    final deps = TurIzimDependencies.of(context);
    final session = TurIzimScope.of(context);
    await deps.assignments.agencySelectApplicant(
      actingAgencyId: session.activeAgencyId!,
      tourId: widget.tourId,
      applicationId: applicationId,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Manuel seçim kaydedildi. Görev bildirimi ve depozito adımları üreticide '
                  'ilerler (mock).',
        ),
      ),
    );
    setState(() => _future = _load());
    await _future;
  }

  Future<void> _openApplicantDetail(
    RatedApplication row,
    TourDetail? tourDetail, {
    required TourMeta meta,
  }) async {
    final selectable = meta.remaining > 0 &&
        row.summary.status == ApplicationStatus.pendingReview;
    await _refreshAfterNavigate(
      Navigator.of(context).push<Object?>(
        MaterialPageRoute<void>(
          builder: (_) => AgencyRatedApplicantDetailScreen(
            rated: row,
            tour: tourDetail,
            canSelect: selectable,
            onManualSelect: () => _selectApplicant(row.summary.id),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmSelectQuick(RatedApplication row) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Manuel seçim onayı'),
        content: const Text(
          'Bu öğrenci içerik üreticisini seçmek için onayınızı veriyorsunuz. Bu bir '
                  'otomatik seçim değildir; nihai karar doğrudan acente '
                  'sorumluluğundadır.\nDevam edelim mi?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Evet')),
        ],
      ),
    );
    if (confirmed == true && mounted) await _selectApplicant(row.summary.id);
  }

  Future<void> _reviewContent(String assignmentId) => _refreshAfterNavigate(
        Navigator.of(context).push<Object?>(
          MaterialPageRoute<void>(
            builder: (_) => AgencyReviewContentDeliveryScreen(
              assignmentId: assignmentId,
            ),
          ),
        ),
      );

  Future<void> _reviewPublication(String assignmentId) => _refreshAfterNavigate(
        Navigator.of(context).push<Object?>(
          MaterialPageRoute<void>(
            builder: (_) => AgencyReviewPublicationScreen(
              assignmentId: assignmentId,
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TurIzimPalette.warmWhite,
      appBar: AppBar(
        backgroundColor: TurIzimPalette.warmWhite,
        foregroundColor: TurIzimPalette.deepNavy,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Başvuran Öğrenci İçerik Üreticileri',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: TurIzimPalette.deepNavy,
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
      body: FutureBuilder<_ApplicantsPayload>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final data = snap.data!;
          final meta = data.meta;
          final tourDetail = data.tour;
          final tourTitle = tourDetail?.title ?? 'Bu ilan';

          return LayoutBuilder(
            builder: (context, constraints) {
              final inset = constraints.maxWidth >
                      TurIzimDesignTokens.maxReadableWidth + 48
                  ? (constraints.maxWidth -
                          TurIzimDesignTokens.maxReadableWidth) /
                      2
                  : TurIzimDesignTokens.pageMargin;

              if (data.rows.isEmpty && data.assignments.isEmpty) {
                return RefreshIndicator.adaptive(
                  onRefresh: () async {
                    setState(() => _future = _load());
                    await _future;
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(inset),
                    children: [
                      _TourContextHeader(
                        tourTitle: tourTitle,
                        meta: meta,
                        tour: tourDetail,
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.12),
                      Icon(
                        Icons.people_outline,
                        size: 56,
                        color: TurIzimPalette.deepNavy.withValues(alpha: 0.26),
                      ),
                      const SizedBox(height: TurIzimDesignTokens.stackMedium),
                      Text(
                        'Bu ilana henüz başvuru yok.',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: TurIzimPalette.deepNavy,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: TurIzimDesignTokens.stackLarge),
                      const SizedBox(height: TurIzimDesignTokens.stackLarge),
                    ],
                  ),
                );
              }

              return RefreshIndicator.adaptive(
                onRefresh: () async {
                  setState(() => _future = _load());
                  await _future;
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        inset,
                        TurIzimDesignTokens.stackSmall,
                        inset,
                        0,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            _TourContextHeader(
                              tourTitle: tourTitle,
                              meta: meta,
                              tour: tourDetail,
                            ),
                            const SizedBox(height: 14),
                            TurIzimInfoBanner(
                              tone: TurIzimStatusTone.info,
                              icon: Icons.policy_rounded,
                              title: 'Karar desteği',
                              message:
                                  'Aday Uygunluk Endeksi, Teknik Kriter Uyumu ve Yayın Platform '
                                          'Uyumu yalnızca seçim sırasında referans için '
                                          'gösterilir.\nBu skorlar karar destek '
                                          'amacıyla sunulmuştur; nihai seçim acenteye aittir. '
                                          'Sistem otomatik atama kullanmaz.',
                            ),
                            const SizedBox(height: 12),
                            const ApplicantSortDisclaimer(),
                          ],
                        ),
                      ),
                    ),
                    if (data.assignments.isNotEmpty)
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          inset,
                          TurIzimDesignTokens.stackMedium,
                          inset,
                          0,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: Text(
                            'Atamalar',
                            style:
                                Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: TurIzimPalette.deepNavy,
                                    ),
                          ),
                        ),
                      ),
                    if (data.assignments.isNotEmpty)
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(inset, 10, inset, 0),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((context, i) {
                            final a = data.assignments[i];
                            final depositLabel = a.depositStatus != null
                                ? mockDepositStatusLabelTurkish(a.depositStatus!)
                                : '—';
                            return Padding(
                              padding:
                                  EdgeInsets.only(bottom: i == data.assignments.length - 1 ? 0 : 12),
                              child: TurIzimSurfaceCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      a.tourTitle ?? a.id,
                                      style:
                                          Theme.of(context).textTheme.titleSmall?.copyWith(
                                                fontWeight: FontWeight.w800,
                                                color: TurIzimPalette.deepNavy,
                                              ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        TurIzimStatusPill(
                                          icon: Icons.badge_rounded,
                                          label:
                                              assignmentStatusLabelTurkish(a.status),
                                        ),
                                        TurIzimStatusPill(
                                          tone: TurIzimStatusTone.warning,
                                          icon: Icons.shield_rounded,
                                          label: 'Depozito (mock): $depositLabel',
                                        ),
                                      ],
                                    ),
                                    if (a.status == AssignmentStatus.waitingAgencyApproval) ...[
                                      const SizedBox(height: 14),
                                      TurIzimPrimaryButton(
                                        icon: Icons.fact_check_outlined,
                                        label: 'İçeriği İncele',
                                        onPressed: () => _reviewContent(a.id),
                                      ),
                                    ],
                                    if (a.status == AssignmentStatus.publicationSubmitted)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 14),
                                        child: TurIzimPrimaryButton(
                                          icon: Icons.article_outlined,
                                          label: 'Yayını İncele',
                                          onPressed: () =>
                                              _reviewPublication(a.id),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }, childCount: data.assignments.length),
                        ),
                      ),
                    if (data.rows.isNotEmpty)
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          inset,
                          TurIzimDesignTokens.stackMedium,
                          inset,
                          0,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: Text(
                            'Başvuran öğrenci içerik üreticileri',
                            style:
                                Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: TurIzimPalette.deepNavy,
                                    ),
                          ),
                        ),
                      ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        inset,
                        12,
                        inset,
                        TurIzimDesignTokens.stackLarge,
                      ),
                      sliver: SliverList.separated(
                        itemCount: data.rows.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 14),
                        itemBuilder: (_, idx) {
                          final row = data.rows[idx];
                          return _RatedApplicantCard(
                            meta: meta,
                            tourTitle: tourTitle,
                            row: row,
                            onInspectDetail: () => _openApplicantDetail(
                              row,
                              tourDetail,
                              meta: meta,
                            ),
                            onQuickConfirm:
                                meta.remaining > 0 &&
                                        row.summary.status ==
                                            ApplicationStatus.pendingReview
                                    ? () => _confirmSelectQuick(row)
                                    : null,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _RatedApplicantCard extends StatelessWidget {
  const _RatedApplicantCard({
    required this.meta,
    required this.tourTitle,
    required this.row,
    required this.onInspectDetail,
    required this.onQuickConfirm,
  });

  final TourMeta meta;
  final String tourTitle;
  final RatedApplication row;

  final VoidCallback onInspectDetail;

  final VoidCallback? onQuickConfirm;

  @override
  Widget build(BuildContext context) {
    final hint = agencyApplicantSelectHint(
      status: row.summary.status,
      remaining: meta.remaining,
    );

    return TurIzimSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  row.creator.displayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: TurIzimPalette.deepNavy,
                      ),
                ),
              ),
              TurIzimStatusPill(label: applicationStatusLabelTurkish(row.summary.status)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'İlan: $tourTitle',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          if (row.creator.studentProfileLine != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.school_outlined,
                      color: TurIzimPalette.royalIndigo, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      row.creator.studentProfileLine!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  TurIzimStatusPill(
                    tone: row.creator.studentVerificationStatus ==
                            StudentVerificationStatus.verified
                        ? TurIzimStatusTone.success
                        : TurIzimStatusTone.neutral,
                    label: studentVerificationStatusLabel(
                      row.creator.studentVerificationStatus,
                    ),
                    icon: Icons.verified_rounded,
                  ),
                ],
              ),
            ),
          if (row.scores.missingRequirementsText.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            DecoratedBox(
              decoration: BoxDecoration(
                color: TurIzimPalette.softCoral.withValues(alpha: 0.10),
                borderRadius:
                    BorderRadius.circular(TurIzimDesignTokens.radiusMedium),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Eksik veya uyarı veren teknik/taşıyıcı kriterler:',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(row.scores.missingRequirementsText),
                  ],
                ),
              ),
            ),
          ],
          if (creatorProfileMockPreviewBullets(row.creator).isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Wrap(
                children: creatorProfileMockPreviewBullets(row.creator)
                    .map(
                      (b) => Padding(
                        padding: const EdgeInsets.only(right: 16, bottom: 4),
                        child: Text(
                          '· $b',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                height: 1.42,
                              ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          const SizedBox(height: TurIzimDesignTokens.stackMedium),
          SuitabilityScoreCard(scores: row.scores),
          const SizedBox(height: TurIzimDesignTokens.stackMedium),
          Row(
            children: [
              Expanded(
                child: TurIzimSecondaryButton(
                  fullWidth: true,
                  label: 'Adayı İncele',
                  icon: Icons.visibility_rounded,
                  onPressed: onInspectDetail,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TurIzimPrimaryButton(
                  fullWidth: true,
                  label: 'Seçimi Onayla',
                  icon: Icons.how_to_reg_rounded,
                  onPressed: onQuickConfirm,
                ),
              ),
            ],
          ),
          if (hint != null && hint.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: TurIzimDesignTokens.stackMedium),
              child: Text(
                hint,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color:
                          Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TourContextHeader extends StatelessWidget {
  const _TourContextHeader({
    required this.tourTitle,
    required this.meta,
    required this.tour,
  });

  final String tourTitle;
  final TourMeta meta;
  final TourDetail? tour;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(TurIzimDesignTokens.radiusExtraLarge),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            TurIzimPalette.softLavender.withValues(alpha: 0.52),
          ],
        ),
        border: Border.all(color: TurIzimPalette.deepNavy.withValues(alpha: 0.06)),
        boxShadow: TurIzimDesignTokens.premiumShadow(),
      ),
      child: Padding(
        padding: const EdgeInsets.all(TurIzimDesignTokens.cardPaddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tourTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: TurIzimPalette.deepNavy,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kota ${meta.quota} · Müsait seçim: ${meta.remaining} · Atanan '
                  '${meta.accepted}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
            if (tour != null) ...[
              const SizedBox(height: 12),
              TourPricingInfoLines(tour: tour!, dense: true),
              const SizedBox(height: 8),
              TourTravelScopeSummaryLines(tour: tour!, dense: true),
            ],
          ],
        ),
      ),
    );
  }
}

String? agencyApplicantSelectHint({
  required ApplicationStatus status,
  required int remaining,
}) {
  if (remaining <= 0) return 'Seçim kotası dolmuş olabilir.';
  return switch (status) {
    ApplicationStatus.accepted =>
      'Bu aday seçildi — atama adımlarını üst bloktan izleyebilirsiniz.',
    ApplicationStatus.rejected => 'Bu başvuru daha önce reddedildi.',
    ApplicationStatus.withdrawn => 'Üretici başvurusunu geri çekmişti.',
    ApplicationStatus.pendingReview => null,
  };
}

class TourMeta {
  const TourMeta({required this.quota, required this.remaining, required this.accepted});

  final int quota;
  final int remaining;
  final int accepted;
}
