import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tur_izim/app/router.dart';
import 'package:tur_izim/app/tur_izim_scope.dart';
import 'package:tur_izim/core/di/tur_izim_dependencies.dart';
import 'package:tur_izim/core/errors/user_error_message.dart';
import 'package:tur_izim/features/auth/presentation/creator_protected_body.dart';
import 'package:tur_izim/shared/models/assignment_status.dart';
import 'package:tur_izim/shared/models/assignment_summary.dart';
import 'package:tur_izim/shared/models/mock_deposit_status.dart';
import 'package:tur_izim/shared/models/tour_detail.dart';
import 'package:tur_izim/shared/presentation/status_label_turkish.dart';
import 'package:tur_izim/shared/presentation/tour_display_format.dart';
import 'package:tur_izim/shared/theme/tur_izim_design_tokens.dart';
import 'package:tur_izim/shared/widgets/tour_visual_header.dart';
import 'package:tur_izim/shared/widgets/tur_izim_info_banner.dart';
import 'package:tur_izim/shared/widgets/tur_izim_metric_card.dart';
import 'package:tur_izim/shared/widgets/tur_izim_primary_button.dart';
import 'package:tur_izim/shared/widgets/tur_izim_surface_card.dart';
import 'package:tur_izim/shared/widgets/tur_izim_status_pill.dart';

class CreatorMyAssignmentsScreen extends StatefulWidget {
  const CreatorMyAssignmentsScreen({super.key});

  @override
  State<CreatorMyAssignmentsScreen> createState() =>
      _CreatorMyAssignmentsScreenState();
}

class _AssignmentsPageBundle {
  const _AssignmentsPageBundle({
    required this.assignments,
    required this.toursById,
  });

  final List<AssignmentSummary> assignments;
  final Map<String, TourDetail?> toursById;
}

class _CreatorMyAssignmentsScreenState extends State<CreatorMyAssignmentsScreen> {
  Future<_AssignmentsPageBundle>? _bundleFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final session = TurIzimScope.of(context);
    if (_bundleFuture == null && session.canAccessProtectedCreatorEndpoints) {
      _bundleFuture = _loadBundle(context);
    }
  }

  Future<_AssignmentsPageBundle> _loadBundle(BuildContext context) async {
    final deps = TurIzimDependencies.of(context);
    final session = TurIzimScope.of(context);
    final creatorId = session.activeCreatorId!;

    final assignments = await deps.assignments.listByCreator(creatorId);
    final ids = assignments.map((a) => a.tourId).toSet().toList(growable: false);
    final tours = await Future.wait(
      ids.map(deps.tours.fetchTourDetail),
    );
    final map = Map<String, TourDetail?>.fromIterables(ids, tours);
    return _AssignmentsPageBundle(assignments: assignments, toursById: map);
  }

  Future<void> _refresh(BuildContext context) async {
    setState(() {
      _bundleFuture = _loadBundle(context);
    });
    await _bundleFuture;
  }

  @override
  Widget build(BuildContext context) {
    final session = TurIzimScope.of(context);

    return Scaffold(
      backgroundColor: TurIzimPalette.warmWhite,
      appBar: AppBar(
        backgroundColor: TurIzimPalette.warmWhite,
        foregroundColor: TurIzimPalette.deepNavy,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Görevlerim',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: TurIzimPalette.deepNavy,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await session.clearSession();
              if (context.mounted) context.go(AppRoutes.welcome);
            },
            style: TextButton.styleFrom(
              foregroundColor: TurIzimPalette.royalIndigo,
            ),
            child: const Text('Çıkış'),
          ),
        ],
      ),
      body: CreatorProtectedBody(
        builder: (context, creatorId) => FutureBuilder<_AssignmentsPageBundle>(
        future: _bundleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(TurIzimDesignTokens.stackMedium),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      userFacingErrorMessage(snapshot.error),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: TurIzimPalette.deepNavy,
                      ),
                    ),
                    const SizedBox(height: TurIzimDesignTokens.stackSmall),
                    TurIzimPrimaryButton(
                      label: 'Yeniden dene',
                      onPressed: () => _refresh(context),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data!;
          final rows = data.assignments;

          if (rows.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => _refresh(context),
              edgeOffset: 80,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  ..._overviewSlivers(rows),
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyAssignmentsState(),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _refresh(context),
            edgeOffset: 96,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                ..._overviewSlivers(rows),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    TurIzimDesignTokens.pageMargin,
                    4,
                    TurIzimDesignTokens.pageMargin,
                    TurIzimDesignTokens.stackLarge,
                  ),
                  sliver: SliverList.separated(
                    itemCount: rows.length,
                    separatorBuilder: (_, _) => const SizedBox(
                      height: TurIzimDesignTokens.stackMedium,
                    ),
                    itemBuilder: (context, idx) => _AssignmentTaskCard(
                      row: rows[idx],
                      detail: data.toursById[rows[idx].tourId],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      ),
    );
  }

  List<Widget> _overviewSlivers(List<AssignmentSummary> assignments) => [
        SliverToBoxAdapter(child: LayoutBuilder(builder: (_, constraints) {
          final inset = constraints.maxWidth > TurIzimDesignTokens.maxReadableWidth + 48
              ? (constraints.maxWidth - TurIzimDesignTokens.maxReadableWidth) / 2
              : TurIzimDesignTokens.pageMargin;
          return Padding(
            padding: EdgeInsets.fromLTRB(
              inset,
              0,
              inset,
              TurIzimDesignTokens.stackMedium,
            ),
            child: _AssignmentsPremiumSummary(assignments: assignments),
          );
        }),),
      ];
}

/// Üst özet hero + küçük metrikler — yalnızca sunum katmanı.
class _AssignmentsPremiumSummary extends StatelessWidget {
  const _AssignmentsPremiumSummary({required this.assignments});

  final List<AssignmentSummary> assignments;

  @override
  Widget build(BuildContext context) {
    final total = assignments.length;
    final actionNeeded = assignments.where(_needsCreatorAction).length;
    final done = assignments
        .where((a) => a.status == AssignmentStatus.completed)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              TurIzimDesignTokens.radiusExtraLarge,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.92),
                TurIzimPalette.softSkyBlue.withValues(alpha: 0.42),
                TurIzimPalette.softLavender.withValues(alpha: 0.52),
              ],
            ),
            border: Border.all(
              color: TurIzimPalette.deepNavy.withValues(alpha: 0.06),
            ),
            boxShadow: TurIzimDesignTokens.premiumShadow(),
          ),
          child: Padding(
            padding: const EdgeInsets.all(TurIzimDesignTokens.cardPaddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: TurIzimPalette.softCoral.withValues(alpha: 0.18),
                        borderRadius:
                            BorderRadius.circular(TurIzimDesignTokens.radiusMedium),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.assignment_turned_in_rounded,
                          color: TurIzimPalette.royalIndigo,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Görevlerim',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: TurIzimPalette.deepNavy,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Seçildiğin turların içerik teslim ve yayın adımlarını '
                  'buradan takip et.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: TurIzimPalette.slateText.withValues(alpha: 0.90),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: TurIzimDesignTokens.stackMedium),
                TurIzimInfoBanner(
                  title: null,
                  icon: Icons.school_rounded,
                  tone: TurIzimStatusTone.info,
                  message:
                      'Üniversite öğrencisi içerik üreticileri için görev takip '
                      'alanı.',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: TurIzimDesignTokens.stackMedium),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 400;
            final cardTotal = TurIzimMetricCard(
              label: 'Toplam görev',
              value: '$total',
              icon: Icons.view_list_rounded,
              accentColor: TurIzimPalette.royalIndigo,
            );
            final cardAction = TurIzimMetricCard(
              label: 'Sıradaki aksiyon',
              value: '$actionNeeded',
              icon: Icons.task_alt_rounded,
              accentColor: TurIzimPalette.softCoral,
              supportingText: 'Tamamlaman gereken adım.',
            );
            final cardDone = TurIzimMetricCard(
              label: 'Tamamlandı',
              value: '$done',
              icon: Icons.verified_rounded,
              accentColor: TurIzimPalette.deepNavy,
            );
            if (stacked) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  cardTotal,
                  const SizedBox(height: TurIzimDesignTokens.stackSmall),
                  cardAction,
                  const SizedBox(height: TurIzimDesignTokens.stackSmall),
                  cardDone,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: cardTotal),
                const SizedBox(width: 12),
                Expanded(child: cardAction),
                const SizedBox(width: 12),
                Expanded(child: cardDone),
              ],
            );
          },
        ),
      ],
    );
  }
}

bool _needsCreatorAction(AssignmentSummary row) =>
    switch (row.status) {
      AssignmentStatus.awaitingCreatorConfirmation => true,
      AssignmentStatus.pendingDeposit => true,
      AssignmentStatus.waitingContentDraft => true,
      AssignmentStatus.revisionRequested => true,
      AssignmentStatus.waitingPublication => true,
      _ => false,
    };

class _EmptyAssignmentsState extends StatelessWidget {
  const _EmptyAssignmentsState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(TurIzimDesignTokens.pageMargin),
      child: Center(
        child: TurIzimSurfaceCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 52,
                color: TurIzimPalette.deepNavy.withValues(alpha: 0.35),
              ),
              const SizedBox(height: TurIzimDesignTokens.stackMedium),
              Text(
                'Henüz atama oluşmadı.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: TurIzimPalette.deepNavy,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Acente seçim sonrasında görevlerin burada listelenir.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: TurIzimPalette.mutedText,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssignmentTaskCard extends StatelessWidget {
  const _AssignmentTaskCard({
    required this.row,
    required this.detail,
  });

  final AssignmentSummary row;
  final TourDetail? detail;

  @override
  Widget build(BuildContext context) {
    final titleText = detail?.title ?? row.tourTitle ?? row.id;

    Widget header;
    final tour = detail;
    if (tour != null) {
      header = TourVisualHeader(
        tour: tour,
        height: 112,
        showLabel: true,
        showTitleOverlay: false,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(TurIzimDesignTokens.radiusLarge),
        ),
      );
    } else {
      header = _PlaceholderTourHeader(title: titleText);
    }

    void openHub() =>
        context.push(AppRoutes.creatorAssignment(row.id));

    return Semantics(
      button: true,
      label: 'Görev: $titleText — detayı aç',
      child: TurIzimSurfaceCard(
        padding: EdgeInsets.zero,
        onTap: openHub,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header,
            Padding(
              padding: const EdgeInsets.all(TurIzimDesignTokens.cardPaddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titleText,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: TurIzimPalette.deepNavy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (_routeDateLine(detail) != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _routeDateLine(detail)!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                  if (row.agencyLegalName != null) ...[
                    const SizedBox(height: 10),
                    _IconLine(
                      icon: Icons.business_outlined,
                      text: 'Acente: ${row.agencyLegalName}',
                    ),
                  ],
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      TurIzimStatusPill(
                        label: assignmentStatusLabelTurkish(row.status),
                        tone: _toneForAssignment(row.status),
                        icon: Icons.flag_outlined,
                      ),
                      TurIzimStatusPill(
                        label: row.depositStatus != null
                            ? 'Depozito: ${mockDepositStatusLabelTurkish(row.depositStatus!)}'
                            : 'Depozito: henüz uygulanmıyor (mock)',
                        tone: row.depositStatus == null
                            ? TurIzimStatusTone.neutral
                            : _toneForDeposit(row.depositStatus!),
                        icon: Icons.shield_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sıradaki aksiyon',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      letterSpacing: 0.55,
                      color: TurIzimPalette.deepNavy.withValues(alpha: 0.55),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _nextActionCopy(row.status),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: TurIzimPalette.slateText,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _VisualMissionTimeline(status: row.status),
                  const SizedBox(height: 18),
                  TurIzimPrimaryButton(
                    icon: Icons.arrow_forward_rounded,
                    label: 'Detay ve aksiyonlar',
                    onPressed: openHub,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tur yükleme yapılamadığında bile kartın premium görünmesi için degrade üst şerit.
class _PlaceholderTourHeader extends StatelessWidget {
  const _PlaceholderTourHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(TurIzimDesignTokens.radiusLarge),
      ),
      child: SizedBox(
        height: 88,
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                TurIzimPalette.softSkyBlue,
                TurIzimPalette.softLavender.withValues(alpha: 0.55),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Row(
                children: [
                  const Icon(
                    Icons.image_not_supported_outlined,
                    color: TurIzimPalette.deepNavy,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: TurIzimPalette.deepNavy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String? _routeDateLine(TourDetail? detail) {
  if (detail == null) return null;
  final overview = tourRouteOverviewLineTurkish(detail);
  final dates =
      '${formatTourCalendarDate(detail.startsAt)} – ${formatTourCalendarDate(detail.endsAt)}';
  return '${detail.departureCity} çıkışlı · $overview · $dates';
}

TurIzimStatusTone _toneForAssignment(AssignmentStatus status) =>
    switch (status) {
      AssignmentStatus.completed => TurIzimStatusTone.success,
      AssignmentStatus.awaitingCreatorConfirmation =>
        TurIzimStatusTone.warning,
      AssignmentStatus.pendingDeposit => TurIzimStatusTone.warning,
      AssignmentStatus.waitingContentDraft => TurIzimStatusTone.info,
      AssignmentStatus.revisionRequested => TurIzimStatusTone.warning,
      AssignmentStatus.waitingPublication => TurIzimStatusTone.info,
      AssignmentStatus.publicationSubmitted => TurIzimStatusTone.success,
      AssignmentStatus.violationReported => TurIzimStatusTone.danger,
      AssignmentStatus.cancelled => TurIzimStatusTone.danger,
      _ => TurIzimStatusTone.neutral,
    };

TurIzimStatusTone _toneForDeposit(MockDepositStatus status) =>
    switch (status) {
      MockDepositStatus.held ||
      MockDepositStatus.releasedAfterPublication =>
        TurIzimStatusTone.success,
      MockDepositStatus.pending =>
        TurIzimStatusTone.warning,
      MockDepositStatus.forfeited =>
        TurIzimStatusTone.danger,
    };

String _nextActionCopy(AssignmentStatus status) =>
    switch (status) {
      AssignmentStatus.awaitingCreatorConfirmation =>
        'Görev detayında üçlü taahhüt ile kesin onayını tamamla (mock '
        'depozito sürecinin bir sonraki adımı).',
      AssignmentStatus.pendingDeposit =>
        'Görev detayına gir; depozito ve taahhüt adımlarını tamamla '
        '(MVP\'de gerçek ödeme yoktur).',
      AssignmentStatus.active =>
        'Görev detayından sıradaki adımı seç; gerekiyorsa taslak veya yayın '
        'bağlantı adımına geç.',
      AssignmentStatus.waitingContentDraft =>
        'Görev detayından taslak yayın bağlantını gönder.',
      AssignmentStatus.waitingAgencyApproval =>
        'Acentenin taslağı incelemesini bekle.',
      AssignmentStatus.revisionRequested =>
        'Acentenin ilettiği notlara göre taslak bağlantını güncelle.',
      AssignmentStatus.waitingPublication =>
        'Yayındaki içerik bağlantını görev detayından bildir '
        '(dış bağlantı; uygulama içi yükleme yok).',
      AssignmentStatus.publicationSubmitted =>
        'Bağlantının doğrulanmasını bekle.',
      AssignmentStatus.depositReleased =>
        'Süreci görev detayından takip et; yayın bildirimi gerekliyse tamamla.',
      AssignmentStatus.under30DayMonitoring =>
        'İçeriğinin en az 30 gün yayında kalması bekleniyor; detayı izle.',
      AssignmentStatus.completed => 'Bu görev tamamlandı. Teşekkürler!',
      AssignmentStatus.violationReported =>
        'İhlal bildirimi oluşmuş olabilir; durumu görev detayından kontrol et.',
      AssignmentStatus.cancelled => 'Bu görev iptal edildi.',
    };

class _IconLine extends StatelessWidget {
  const _IconLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            icon,
            size: 18,
            color: TurIzimPalette.deepNavy.withValues(alpha: 0.42),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
          ),
        ),
      ],
    );
  }
}

/// Beş adımlı salt görsel zaman çizelgesi; iş kuralı yoktur.
class _VisualMissionTimeline extends StatelessWidget {
  const _VisualMissionTimeline({required this.status});

  final AssignmentStatus status;

  static const _labels = <String>[
    'Başvuru kabul edildi',
    'Depozito onayı',
    'İçerik teslimi',
    'Yayın bildirimi',
    'Tamamlandı',
  ];

  @override
  Widget build(BuildContext context) {
    final states = _stepStates(status);
    return TurIzimSurfaceCard(
      usePremiumShadow: false,
      padding: const EdgeInsets.all(TurIzimDesignTokens.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Görsel süreç özeti',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: TurIzimPalette.deepNavy,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bu çizelge bilgilendirme amaçlıdır; sıradaki adımı görev '
            'detayında tamamla.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: TurIzimPalette.mutedText,
                  height: 1.35,
                ),
          ),
          const SizedBox(height: TurIzimDesignTokens.stackMedium),
          for (var i = 0; i < _labels.length; i++) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.only(left: 9),
                child: SizedBox(
                  height: 8,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 2,
                      color: TurIzimPalette.deepNavy.withValues(alpha: 0.10),
                    ),
                  ),
                ),
              ),
            _TimelineRow(label: _labels[i], visual: states[i]),
          ],
        ],
      ),
    );
  }

  List<_TimelineStepVisual> _stepStates(AssignmentStatus s) {
    if (s == AssignmentStatus.cancelled) {
      return List<_TimelineStepVisual>.filled(
          _labels.length, _TimelineStepVisual.muted,);
    }
    if (s == AssignmentStatus.completed) {
      return List<_TimelineStepVisual>.filled(
          _labels.length, _TimelineStepVisual.completed,);
    }
    final focus = switch (s) {
      AssignmentStatus.awaitingCreatorConfirmation ||
      AssignmentStatus.pendingDeposit =>
          1,
      AssignmentStatus.active ||
      AssignmentStatus.waitingContentDraft ||
      AssignmentStatus.waitingAgencyApproval ||
      AssignmentStatus.revisionRequested =>
          2,
      AssignmentStatus.waitingPublication => 3,
      AssignmentStatus.publicationSubmitted ||
      AssignmentStatus.depositReleased =>
          4,
      AssignmentStatus.under30DayMonitoring ||
      AssignmentStatus.violationReported =>
          5,
      AssignmentStatus.completed =>
          throw StateError('completed handled above'),
      AssignmentStatus.cancelled =>
          throw StateError('cancelled handled above'),
    };

    return List<_TimelineStepVisual>.generate(_labels.length, (i) {
      if (i + 1 < focus) return _TimelineStepVisual.completed;
      if (i + 1 == focus) return _TimelineStepVisual.active;
      return _TimelineStepVisual.todo;
    }, growable: false);
  }
}

enum _TimelineStepVisual { completed, active, todo, muted }

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.label, required this.visual});

  final String label;
  final _TimelineStepVisual visual;

  @override
  Widget build(BuildContext context) {
    final (circle, foreground) = switch (visual) {
      _TimelineStepVisual.completed => (
          TurIzimPalette.royalIndigo,
          TurIzimPalette.deepNavy,
        ),
      _TimelineStepVisual.active =>
        (
          TurIzimPalette.softCoral,
          TurIzimPalette.deepNavy,
        ),
      _TimelineStepVisual.todo => (
          TurIzimPalette.deepNavy.withValues(alpha: 0.12),
          TurIzimPalette.mutedText,
        ),
      _TimelineStepVisual.muted => (
          TurIzimPalette.deepNavy.withValues(alpha: 0.08),
          TurIzimPalette.mutedText.withValues(alpha: 0.65),
        ),
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: circle,
            shape: BoxShape.circle,
            border: Border.all(
              color: TurIzimPalette.deepNavy.withValues(
                alpha:
                    visual == _TimelineStepVisual.completed ? 0.12 : 0.18,
              ),
            ),
          ),
          child: visual == _TimelineStepVisual.completed
              ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
              : visual == _TimelineStepVisual.active
                  ? Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: TurIzimPalette.deepNavy,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: visual == _TimelineStepVisual.active
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: foreground,
                ),
          ),
        ),
      ],
    );
  }
}




