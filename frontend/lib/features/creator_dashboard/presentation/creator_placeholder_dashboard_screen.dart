import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tur_izim/app/router.dart';
import 'package:tur_izim/app/tur_izim_scope.dart';
import 'package:tur_izim/core/constants/app_constants.dart';

/// Placeholder dashboard for the eventual creator MVP shell.
class CreatorPlaceholderDashboardScreen extends StatelessWidget {
  const CreatorPlaceholderDashboardScreen({super.key});

  static const String headline = 'İçerik üreticisi yer tutucusu';

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
      body: Center(
        child: Text(
          'Bu MVP diliminde içerik üreticisi akışı oluşturulmadı. '
          '${AppConstants.appName} pilotu yakında bağlanır.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
