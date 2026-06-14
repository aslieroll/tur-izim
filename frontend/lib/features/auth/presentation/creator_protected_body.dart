import 'package:flutter/material.dart';

import 'package:tur_izim/app/tur_izim_scope.dart';
import 'package:tur_izim/features/auth/data/session_auth_repository.dart';
import 'package:tur_izim/features/auth/presentation/auth_required_panel.dart';

/// Korumalı creator ekranları: JWT yoksa API çağrısı yapmadan giriş isteği gösterir.
class CreatorProtectedBody extends StatelessWidget {
  const CreatorProtectedBody({
    required this.builder,
    super.key,
    this.authPanel = const AuthRequiredPanel(),
  });

  final Widget Function(BuildContext context, String creatorId) builder;
  final Widget authPanel;

  static bool canAccess(SessionAuthRepository session) =>
      session.canAccessProtectedCreatorEndpoints;

  @override
  Widget build(BuildContext context) {
    final session = TurIzimScope.of(context);
    final creatorId = session.activeCreatorId;
    if (!session.canAccessProtectedCreatorEndpoints || creatorId == null) {
      return authPanel;
    }
    return builder(context, creatorId);
  }
}
