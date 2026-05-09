import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tur_izim/app/router.dart';
import 'package:tur_izim/app/tur_izim_scope.dart';

/// Minimal admin dashboard placeholder until review queues arrive.
class AdminPlaceholderDashboardScreen extends StatelessWidget {
  const AdminPlaceholderDashboardScreen({super.key});

  static const String headline = 'Yönetici yer tutucusu';

  @override
  Widget build(BuildContext context) {
    final session = TurIzimScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(headline),
        actions: [
          TextButton(
            onPressed: () async {
              await session.clearSession();
              if (!context.mounted) {
                return;
              }
              context.go(AppRoutes.welcome);
            },
            child: const Text('Çıkış'),
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Burada daha sonra acente onayları ve ihlal incelemesi gibi '
          'yönetişim aksiyonları olacaktır.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
