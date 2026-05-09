import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tur_izim/app/router.dart';
import 'package:tur_izim/app/tur_izim_scope.dart';
import 'package:tur_izim/core/constants/app_constants.dart';
import 'package:tur_izim/core/di/tur_izim_dependencies.dart';
import 'package:tur_izim/features/admin_dashboard/presentation/admin_agency_approval_detail_screen.dart';
import 'package:tur_izim/features/admin_dashboard/presentation/admin_violation_review_screen.dart';
import 'package:tur_izim/shared/models/pending_agency_review.dart';
import 'package:tur_izim/shared/models/tour_summary.dart';
import 'package:tur_izim/shared/models/violation_report.dart';
import 'package:tur_izim/shared/models/violation_report_status.dart';
import 'package:tur_izim/shared/presentation/agency_status_label_turkish.dart';
import 'package:tur_izim/shared/presentation/status_label_turkish.dart';
import 'package:tur_izim/shared/theme/tur_izim_design_tokens.dart';
import 'package:tur_izim/shared/widgets/tur_izim_info_banner.dart';
import 'package:tur_izim/shared/widgets/tur_izim_metric_card.dart';
import 'package:tur_izim/shared/widgets/tur_izim_status_pill.dart';
import 'package:tur_izim/shared/widgets/tur_izim_surface_card.dart';

typedef AdminConsoleSnapshot = ({
  List<PendingAgencyReview> pendingAgencies,
  List<ViolationReport> violations,
  List<TourSummary> publishedTours,
});

String _previewViolationReason(String raw) {
  final t = raw.trim();
  if (t.isEmpty) return 'Gerekçe metni bekleniyor.';
  if (t.length <= 90) return t;
  return '${t.substring(0, 87)}…';
}

/// Operasyon özeti · manuel onay ve ihlal kuyrukları (mock).
class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  Future<AdminConsoleSnapshot>? _future;

  Future<AdminConsoleSnapshot> _load() async {
    final deps = TurIzimDependencies.of(context);
    final pendingAgencies = await deps.adminDashboard.listPendingApprovals();
    final violations = await deps.violations.listForAdmin();
    final publishedTours = await deps.tours.fetchPublishedTours();
    return (
      pendingAgencies: pendingAgencies,
      violations: violations,
      publishedTours: publishedTours,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  Iterable<ViolationReport> _actionableViolations(List<ViolationReport> rows) =>
      rows.where(
        (v) =>
            v.status == ViolationReportStatus.open ||
            v.status == ViolationReportStatus.underReview,
      );

  @override
  Widget build(BuildContext context) {
    final session = TurIzimScope.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: TurIzimPalette.warmWhite,
      appBar: AppBar(
        title: Text(
          'Admin Paneli',
          style: theme.textTheme.titleLarge?.copyWith(
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
              if (!context.mounted) return;
              context.go(AppRoutes.welcome);
            },
            child: const Text('Çıkış'),
          ),
        ],
      ),
      body: FutureBuilder<AdminConsoleSnapshot>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          final data = snap.data;
          if (data == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.pageHorizontalMargin),
                child: Text(
                  snap.error?.toString() ?? 'Özet okunamadı.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            );
          }

          final openViolationCount = _actionableViolations(data.violations).length;
          final toursPendingApps = data.publishedTours
              .where((t) => t.pendingApplicationCount > 0)
              .length;

          return RefreshIndicator.adaptive(
            onRefresh: _refresh,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final inset = TurIzimDesignTokens.pageMargin;
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(inset, 12, inset, 32),
                  children: [
                    TurIzimInfoBanner(
                      tone: TurIzimStatusTone.info,
                      icon: Icons.grid_view_rounded,
                      title: 'Operasyon panosu',
                      message:
                          'Onay ve ihlal akışları manuel olarak yürütülür. '
                                  'Üniversite öğrencisi içerik üreticisi atamaları '
                                  'yalnızca acente sorumlusuna aittir; bu panelde '
                                  'acente kayıt onayı ile ihlal bildirimlerinin '
                                  'incelemesini yönetirsiniz.',
                    ),
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (_, box) {
                        final wide = box.maxWidth > 720;
                        if (wide) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TurIzimMetricCard(
                                  icon: Icons.apartment_rounded,
                                  label: 'Onay bekleyen acente',
                                  value: '${data.pendingAgencies.length}',
                                  accentColor: TurIzimPalette.royalIndigo,
                                  supportingText:
                                      data.pendingAgencies.isEmpty ? 'Boş kuyruk' : 'İncelemeye hazır',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TurIzimMetricCard(
                                  icon: Icons.report_outlined,
                                  label: 'İhlal incelemeleri',
                                  value: '$openViolationCount',
                                  accentColor: TurIzimPalette.softCoral,
                                  supportingText: 'Karar gerektiren açık dosya',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TurIzimMetricCard(
                                  icon: Icons.explore_outlined,
                                  label: 'Yayımdaki ilanlar',
                                  value: '${data.publishedTours.length}',
                                  supportingText:
                                      '$toursPendingApps başvuru kuyruk taşıyan ilan',
                                ),
                              ),
                            ],
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TurIzimMetricCard(
                              icon: Icons.apartment_rounded,
                              label: 'Onay bekleyen acente',
                              value: '${data.pendingAgencies.length}',
                              accentColor: TurIzimPalette.royalIndigo,
                              supportingText:
                                  data.pendingAgencies.isEmpty ? 'Boş kuyruk' : 'İncelemeye hazır',
                            ),
                            const SizedBox(height: 12),
                            TurIzimMetricCard(
                              icon: Icons.report_outlined,
                              label: 'İhlal incelemeleri',
                              value: '$openViolationCount',
                              accentColor: TurIzimPalette.softCoral,
                              supportingText: 'Karar gerektiren açık dosya',
                            ),
                            const SizedBox(height: 12),
                            TurIzimMetricCard(
                              icon: Icons.explore_outlined,
                              label: 'Yayımdaki ilanlar',
                              value: '${data.publishedTours.length}',
                              supportingText:
                                  '$toursPendingApps başvuru kuyruk taşıyan ilan',
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 26),
                    Text(
                      'Kuyruk',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: TurIzimPalette.deepNavy,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (data.pendingAgencies.isEmpty)
                      TurIzimSurfaceCard(
                        child: Text(
                          'Onay bekleyen acente yok.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      )
                    else
                      ...data.pendingAgencies.map(
                        (a) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: TurIzimSurfaceCard(
                            onTap: () async {
                              final changed = await Navigator.of(context).push<bool>(
                                MaterialPageRoute<bool>(
                                  builder: (_) => AdminAgencyApprovalDetailScreen(agency: a),
                                ),
                              );
                              if (changed == true && mounted) await _refresh();
                            },
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        a.legalName,
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: TurIzimStatusPill(
                                          tone: TurIzimStatusTone.warning,
                                          icon: Icons.timer_outlined,
                                          label: agencyStatusLabelTurkish(a.status),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: TurIzimPalette.deepNavy.withValues(
                                    alpha: 0.42,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    Text(
                      'İhlaller',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: TurIzimPalette.deepNavy,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_actionableViolations(data.violations).isEmpty)
                      TurIzimSurfaceCard(
                        child: Text(
                          'Açık ihlal incelemesi yok.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      )
                    else
                      ..._actionableViolations(data.violations).map(
                        (v) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: TurIzimSurfaceCard(
                            onTap: () async {
                              final changed =
                                  await Navigator.of(context).push<bool>(
                                        MaterialPageRoute<bool>(
                                          builder: (_) =>
                                              AdminViolationReviewScreen(violation: v),
                                        ),
                                      );
                              if (changed == true && mounted) await _refresh();
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _previewViolationReason(v.reason),
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                              height: 1.42,
                                            ),
                                      ),
                                      const SizedBox(height: 10),
                                      TurIzimStatusPill(
                                        tone: TurIzimStatusTone.warning,
                                        label: violationReportStatusLabelTurkish(
                                          v.status,
                                        ),
                                        icon: Icons.rule_folder_outlined,
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: TurIzimPalette.deepNavy.withValues(
                                    alpha: 0.42,
                                  ),
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
        },
      ),
    );
  }
}
