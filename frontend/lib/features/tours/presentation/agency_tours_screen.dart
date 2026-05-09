import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tur_izim/app/router.dart';
import 'package:tur_izim/app/tur_izim_scope.dart';
import 'package:tur_izim/core/di/tur_izim_dependencies.dart';
import 'package:tur_izim/shared/models/tour_summary.dart';
import 'package:tur_izim/shared/presentation/status_label_turkish.dart';
import 'package:tur_izim/shared/widgets/status_badge.dart';
import 'package:tur_izim/shared/widgets/tour_pricing_info_lines.dart';
import 'package:tur_izim/shared/widgets/tour_travel_scope_summary_lines.dart';

class AgencyToursScreen extends StatelessWidget {
  const AgencyToursScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deps = TurIzimDependencies.of(context);
    final session = TurIzimScope.of(context);
    final agencyId = session.activeAgencyId!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('İlanlarım'),
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
      body: FutureBuilder<List<TourSummary>>(
        future: deps.tours.fetchAgencyTours(agencyId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final rows = snapshot.data ?? const [];
          if (rows.isEmpty) {
            return const Center(child: Text('Kayıtlı tur yok.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: rows.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (ctx, idx) {
              final t = rows[idx];
              return ListTile(
                title: Text(t.title),
                isThreeLine: true,
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Başvurular bekleyen ${t.pendingApplicationCount} • '
                      'Atanan ${t.acceptedAssignmentCount}/${t.creatorQuota}',
                    ),
                    const SizedBox(height: 6),
                    TourTravelScopeSummaryLines(tour: t, dense: true),
                    const SizedBox(height: 6),
                    TourPricingInfoLines(tour: t, dense: true),
                  ],
                ),
                trailing: StatusBadge(label: tourStatusLabelTurkish(t.status)),
                onTap: () => context.push(AppRoutes.agencyApplicants(t.id)),
              );
            },
          );
        },
      ),
    );
  }
}
