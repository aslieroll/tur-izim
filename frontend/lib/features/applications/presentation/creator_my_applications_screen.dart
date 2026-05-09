import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tur_izim/app/router.dart';
import 'package:tur_izim/app/tur_izim_scope.dart';
import 'package:tur_izim/core/di/tur_izim_dependencies.dart';
import 'package:tur_izim/core/errors/app_exception.dart';
import 'package:tur_izim/shared/models/application_status.dart';
import 'package:tur_izim/shared/models/application_summary.dart';
import 'package:tur_izim/shared/presentation/status_label_turkish.dart';
import 'package:tur_izim/shared/theme/tur_izim_design_tokens.dart';
import 'package:tur_izim/shared/widgets/tur_izim_info_banner.dart';
import 'package:tur_izim/shared/widgets/tur_izim_secondary_button.dart';
import 'package:tur_izim/shared/widgets/tur_izim_surface_card.dart';
import 'package:tur_izim/shared/widgets/tur_izim_status_pill.dart';

class CreatorMyApplicationsScreen extends StatefulWidget {
  const CreatorMyApplicationsScreen({super.key});

  @override
  State<CreatorMyApplicationsScreen> createState() =>
      _CreatorMyApplicationsScreenState();
}

class _CreatorMyApplicationsScreenState
    extends State<CreatorMyApplicationsScreen> {
  Future<List<ApplicationSummary>>? _future;

  Future<void> _reload() async {
    final deps = TurIzimDependencies.of(context);
    final session = TurIzimScope.of(context);
    setState(() {
      _future = deps.applications.listByCreator(session.activeCreatorId!);
    });
    await _future;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  Future<void> _withdraw(ApplicationSummary app) async {
    final deps = TurIzimDependencies.of(context);
    final session = TurIzimScope.of(context);
    try {
      await deps.applications.withdrawApplication(
        applicationId: app.id,
        creatorId: session.activeCreatorId!,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Başvuru geri çekildi.')));
      await _reload();
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  List<Widget> _summaryIntroSlivers() => [
        SliverToBoxAdapter(
          child: LayoutBuilder(builder: (_, constraints) {
            final inset = constraints.maxWidth >
                    TurIzimDesignTokens.maxReadableWidth + 48
                ? (constraints.maxWidth -
                        TurIzimDesignTokens.maxReadableWidth) /
                    2
                : TurIzimDesignTokens.pageMargin;
            return Padding(
              padding: EdgeInsets.fromLTRB(
                inset,
                0,
                inset,
                TurIzimDesignTokens.stackMedium,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    TurIzimDesignTokens.radiusExtraLarge,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.92),
                      TurIzimPalette.softLavender.withValues(alpha: 0.42),
                      TurIzimPalette.softSkyBlue.withValues(alpha: 0.42),
                    ],
                  ),
                  border: Border.all(
                    color: TurIzimPalette.deepNavy.withValues(alpha: 0.06),
                  ),
                  boxShadow: TurIzimDesignTokens.premiumShadow(),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(
                    TurIzimDesignTokens.cardPaddingLarge,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: TurIzimPalette.softCoral
                                  .withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(
                                TurIzimDesignTokens.radiusMedium,
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(10),
                              child: Icon(
                                Icons.edit_note_rounded,
                                color: TurIzimPalette.royalIndigo,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Başvurularım',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: TurIzimPalette.deepNavy,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: TurIzimDesignTokens.stackSmall),
                      Text(
                        'Yayımdaki tur ilanları için oluşturduğun görev başvurularını '
                        'burada görürsün.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color:
                                  TurIzimPalette.slateText.withValues(alpha: 0.90),
                              height: 1.42,
                            ),
                      ),
                      const SizedBox(height: TurIzimDesignTokens.stackMedium),
                      TurIzimInfoBanner(
                        tone: TurIzimStatusTone.info,
                        icon: Icons.insights_rounded,
                        title: 'Karar desteği',
                        message:
                            'Aday Uygunluk Endeksi (AUE), acenteye seçim sırasında '
                            'bakış katmanı sağlar. Nihai seçim ve atama doğrudan '
                            'acentenin sorumluluğundadır.',
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ];

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
          'Başvurularım',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: TurIzimPalette.deepNavy,
                fontWeight: FontWeight.w700,
              ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await session.clearSession();
              if (context.mounted) {
                context.go(AppRoutes.welcome);
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: TurIzimPalette.royalIndigo,
            ),
            child: const Text('Çıkış'),
          ),
        ],
      ),
      body: FutureBuilder<List<ApplicationSummary>>(
        future: _future,
        builder: (context, snap) {
          if (_future == null ||
              snap.connectionState == ConnectionState.waiting ||
              snap.data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final rows = snap.data!;
          if (rows.isEmpty) {
            return RefreshIndicator(
              onRefresh: _reload,
              edgeOffset: 80,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  ..._summaryIntroSlivers(),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(TurIzimDesignTokens.pageMargin),
                        child: TurIzimSurfaceCard(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.outbox_outlined,
                                size: 48,
                                color: TurIzimPalette.deepNavy
                                    .withValues(alpha: 0.32),
                              ),
                              const SizedBox(
                                height: TurIzimDesignTokens.stackMedium,
                              ),
                              Text(
                                'Kayıtlı başvuru yok.',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                  color: TurIzimPalette.deepNavy,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Uygun gördüğün ilan için başvurunu oluştur; '
                                'üniversite öğrencisi içerik üreticisi profilin '
                                'özetlenir.',
                                textAlign: TextAlign.center,
                                style:
                                    Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: TurIzimPalette.mutedText,
                                          height: 1.38,
                                        ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                ..._summaryIntroSlivers(),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    TurIzimDesignTokens.pageMargin,
                    0,
                    TurIzimDesignTokens.pageMargin,
                    TurIzimDesignTokens.stackLarge,
                  ),
                  sliver: SliverList.separated(
                    itemCount: rows.length,
                    separatorBuilder: (_, _) => const SizedBox(
                      height: TurIzimDesignTokens.stackMedium,
                    ),
                    itemBuilder: (ctx, idx) =>
                        _CreatorApplicationPremiumCard(
                      app: rows[idx],
                      onWithdraw: rows[idx].status ==
                              ApplicationStatus.pendingReview
                          ? () => _withdraw(rows[idx])
                          : null,
                    ),
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

class _CreatorApplicationPremiumCard extends StatelessWidget {
  const _CreatorApplicationPremiumCard({
    required this.app,
    required this.onWithdraw,
  });

  final ApplicationSummary app;
  final VoidCallback? onWithdraw;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = app.tourTitle ?? 'Tur ${app.tourId}';
    final agency = app.agencyLegalName ?? '—';
    final aueLine = app.suitabilityAue != null
        ? 'Aday Uygunluk Endeksi: ${app.suitabilityAue!.round()}/100'
        : 'Aday Uygunluk Endeksi: —';

    return TurIzimSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: TurIzimPalette.deepNavy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TurIzimStatusPill(
                tone: TurIzimStatusTone.neutral,
                icon: Icons.assignment_turned_in_outlined,
                label: applicationStatusLabelTurkish(app.status),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Acente: $agency',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          TurIzimSurfaceCard(
            usePremiumShadow: false,
            padding: const EdgeInsets.all(TurIzimDesignTokens.cardPadding),
            borderColor: TurIzimPalette.royalIndigo.withValues(alpha: 0.12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  aueLine,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: TurIzimPalette.deepNavy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'AUE yalnızca karar desteğidir; nihai seçim acente tarafından '
                  'yapılır.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: TurIzimPalette.mutedText,
                    height: 1.42,
                  ),
                ),
              ],
            ),
          ),
          if (app.message != null && app.message!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Not: ${app.message}',
              style: theme.textTheme.bodyMedium,
            ),
          ],
          if (onWithdraw != null) ...[
            const SizedBox(height: TurIzimDesignTokens.stackMedium),
            TurIzimSecondaryButton(
              label: 'Başvuruyu çek',
              icon: Icons.undo_rounded,
              fullWidth: true,
              onPressed: onWithdraw,
            ),
          ],
        ],
      ),
    );
  }
}
