import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tur_izim/app/router.dart';
import 'package:tur_izim/app/tur_izim_scope.dart';
import 'package:tur_izim/core/di/tur_izim_dependencies.dart';
import 'package:tur_izim/core/errors/app_exception.dart';
import 'package:tur_izim/core/errors/user_error_message.dart';
import 'package:tur_izim/shared/models/application_commitment.dart';
import 'package:tur_izim/shared/models/assignment_detail.dart';
import 'package:tur_izim/shared/models/assignment_status.dart';
import 'package:tur_izim/shared/models/assignment_timeline_step.dart';
import 'package:tur_izim/shared/presentation/status_label_turkish.dart';
import 'package:tur_izim/shared/presentation/tour_display_format.dart';
import 'package:tur_izim/shared/widgets/assignment_timeline.dart';
import 'package:tur_izim/shared/widgets/mandatory_application_checkboxes.dart';
import 'package:tur_izim/shared/widgets/status_badge.dart';
import 'package:tur_izim/shared/widgets/tour_pricing_info_lines.dart';

class CreatorAssignmentHubScreen extends StatefulWidget {
  const CreatorAssignmentHubScreen({required this.assignmentId, super.key});

  final String assignmentId;

  @override
  State<CreatorAssignmentHubScreen> createState() =>
      _CreatorAssignmentHubScreenState();
}

class _CreatorAssignmentHubScreenState
    extends State<CreatorAssignmentHubScreen> {
  Future<({AssignmentDetail detail, List<AssignmentTimelineStep> steps})>?
  _bundle;

  ApplicationCommitment _finalCommitment = const ApplicationCommitment(
    acceptedPublicationCommitment: false,
    acceptedContentUsagePermission: false,
    acceptedTourPriceClaimCondition: false,
  );

  bool _finalBusy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bundle ??= _load();
  }

  Future<({AssignmentDetail detail, List<AssignmentTimelineStep> steps})>
  _load() async {
    final deps = TurIzimDependencies.of(context);
    final session = TurIzimScope.of(context);
    final creatorId = session.activeCreatorId!;

    final detail = await deps.assignments.loadAssignmentDetail(
      assignmentId: widget.assignmentId,
      viewerCreatorId: creatorId,
      viewerAgencyId: null,
    );
    if (detail == null) {
      throw StateError('Atama bulunamadı.');
    }

    final steps = await deps.assignments.loadTimeline(
      assignmentId: widget.assignmentId,
      viewerCreatorId: creatorId,
      viewerAgencyId: null,
    );

    return (detail: detail, steps: steps);
  }

  Future<void> _refresh() async {
    setState(() => _bundle = _load());
    await _bundle;
  }

  Future<void> _submitFinalApproval() async {
    final deps = TurIzimDependencies.of(context);
    final session = TurIzimScope.of(context);
    setState(() => _finalBusy = true);
    try {
      await deps.assignments.creatorConfirmDeposit(
        assignmentId: widget.assignmentId,
        creatorId: session.activeCreatorId!,
        commitment: _finalCommitment,
      );
      if (!mounted) return;
      await _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Kesin onayınız kaydedildi. Mock depozito HELD durumuna alındı '
            '(gerçek ödeme yok).',
          ),
        ),
      );
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _finalBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atama detayı'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        ],
      ),
      body:
          FutureBuilder<
            ({AssignmentDetail detail, List<AssignmentTimelineStep> steps})
          >(
            future: _bundle,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text(userFacingErrorMessage(snapshot.error)));
              }
              if (snapshot.connectionState == ConnectionState.waiting ||
                  snapshot.data == null) {
                return const Center(child: CircularProgressIndicator());
              }
              final data = snapshot.data!;
              final hub = data.detail;
              final scheme = Theme.of(context).colorScheme;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      StatusBadge(
                        label: assignmentStatusLabelTurkish(hub.summary.status),
                      ),
                      if (hub.deposit != null)
                        StatusBadge(
                          label: mockDepositStatusLabelTurkish(
                            hub.deposit!.status,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    hub.tour.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Çıkış şehri: ${hub.tour.departureCity}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tur rotası: ${tourRouteOverviewLineTurkish(hub.tour)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tur tarihleri: '
                    '${formatTourCalendarDate(hub.tour.startsAt)} – '
                    '${formatTourCalendarDate(hub.tour.endsAt)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  if (hub.tour.agencyLegalName != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Acente: ${agencyDisplayLineWithCityTurkish(hub.tour)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    'İlan fiyat özeti (salt okunur)',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 6),
                  TourPricingInfoLines(tour: hub.tour),
                  if (hub.applicationMessage != null &&
                      hub.applicationMessage!.trim().isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Card.outlined(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Seçilen başvuru notunuz',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(hub.applicationMessage!),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (hub.deposit != null) ...[
                    const SizedBox(height: 16),
                    Card.outlined(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mock depozito (MVP simülasyonu)',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tur İzim gerçek para hareketini sürdürmez ve '
                              'kart doğrulama verisi toplamaz. Bu tutar yalnızca '
                              'mock depozito senaryosu içindir.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tutar (anlık görüntü): '
                              '${hub.deposit!.amountSnapshot.toStringAsFixed(0)} '
                              '(birim mock)',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Durum: '
                              '${mockDepositStatusLabelTurkish(hub.deposit!.status)}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (hub.summary.status ==
                      AssignmentStatus.awaitingCreatorConfirmation) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Kesin onay',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Aşağıdaki üç şartı yeniden onaylamanız gerekir. Onay '
                      'sonrası mock depozito PENDING→HELD olarak işlenir.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    MandatoryApplicationCheckboxes(
                      onChanged: (c) => setState(() => _finalCommitment = c),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: (_finalCommitment.isComplete && !_finalBusy)
                          ? _submitFinalApproval
                          : null,
                      child: Text(
                        _finalBusy
                            ? 'Kaydediliyor…'
                            : 'Kesin onayı ver (mock depozito HELD)',
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  AssignmentTimeline(steps: data.steps),
                  const Divider(height: 32),
                  if (hub.summary.status == AssignmentStatus.pendingDeposit)
                    ElevatedButton(
                      onPressed: () => context.push(
                        AppRoutes.creatorDeposit(widget.assignmentId),
                      ),
                      child: const Text('Depozito / taahhüt yeniden onayı'),
                    ),
                  if (hub.summary.status ==
                          AssignmentStatus.waitingContentDraft ||
                      hub.summary.status == AssignmentStatus.revisionRequested)
                    ElevatedButton(
                      onPressed: () => context.push(
                        AppRoutes.creatorDraft(widget.assignmentId),
                      ),
                      child: const Text('Taslak URL gönder'),
                    ),
                  if (hub.summary.status == AssignmentStatus.waitingPublication)
                    ElevatedButton(
                      onPressed: () => context.push(
                        AppRoutes.creatorPublication(widget.assignmentId),
                      ),
                      child: const Text('Yayın URL bildir'),
                    ),
                  if (hub.publication?.monitoringEndDate != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Card.outlined(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '30 günlük izlemeye giriş (mock tarihler)',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Başlangıç: '
                                '${hub.publication!.monitoringStartDate}\n'
                                'Bitiş: ${hub.publication!.monitoringEndDate}',
                              ),
                            ],
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
