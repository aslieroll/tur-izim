import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tur_izim/app/router.dart';
import 'package:tur_izim/app/tur_izim_scope.dart';
import 'package:tur_izim/core/di/tur_izim_dependencies.dart';
import 'package:tur_izim/core/errors/app_exception.dart';
import 'package:tur_izim/shared/models/application_status.dart';
import 'package:tur_izim/shared/models/application_summary.dart';
import 'package:tur_izim/shared/presentation/status_label_turkish.dart';
import 'package:tur_izim/shared/widgets/status_badge.dart';

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

  @override
  Widget build(BuildContext context) {
    final session = TurIzimScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Başvurularım'),
        actions: [
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
            return const Center(child: Text('Kayıtlı başvuru yok.'));
          }

          final theme = Theme.of(context);
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: rows.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (ctx, idx) {
              final app = rows[idx];
              final title = app.tourTitle ?? 'Tur ${app.tourId}';
              final agency = app.agencyLegalName ?? '—';
              final aueLine = app.suitabilityAue != null
                  ? 'Aday Uygunluk Endeksi: '
                        '${app.suitabilityAue!.round()}/100'
                  : 'Aday Uygunluk Endeksi: —';

              return Card.outlined(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Text('Acente: $agency'),
                      Text(applicationStatusLabelTurkish(app.status)),
                      const SizedBox(height: 4),
                      Text(
                        aueLine,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (app.message != null && app.message!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text('Not: ${app.message}'),
                      ],
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Wrap(
                          spacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            StatusBadge(
                              label: applicationStatusLabelTurkish(app.status),
                            ),
                            if (app.status == ApplicationStatus.pendingReview)
                              TextButton(
                                onPressed: () => _withdraw(app),
                                child: const Text('Çek'),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
