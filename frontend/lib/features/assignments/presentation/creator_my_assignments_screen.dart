import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tur_izim/app/router.dart';
import 'package:tur_izim/app/tur_izim_scope.dart';
import 'package:tur_izim/core/di/tur_izim_dependencies.dart';
import 'package:tur_izim/shared/models/assignment_summary.dart';
import 'package:tur_izim/shared/presentation/status_label_turkish.dart';
import 'package:tur_izim/shared/widgets/status_badge.dart';

class CreatorMyAssignmentsScreen extends StatelessWidget {
  const CreatorMyAssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deps = TurIzimDependencies.of(context);
    final session = TurIzimScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Görevlerim'),
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
      body: FutureBuilder<List<AssignmentSummary>>(
        future: deps.assignments.listByCreator(session.activeCreatorId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final rows = snapshot.data ?? const [];
          if (rows.isEmpty) {
            return const Center(child: Text('Henüz atama oluşmadı.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: rows.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (context, idx) {
              final row = rows[idx];
              return ListTile(
                title: Text(row.tourTitle ?? row.id),
                subtitle: Text(
                  row.agencyLegalName != null
                      ? 'Acente: ${row.agencyLegalName}'
                      : 'Tur: ${row.tourId}',
                ),
                trailing: StatusBadge(
                  label: assignmentStatusLabelTurkish(row.status),
                ),
                onTap: () => context.push(AppRoutes.creatorAssignment(row.id)),
              );
            },
          );
        },
      ),
    );
  }
}
