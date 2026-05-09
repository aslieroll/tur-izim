import 'package:flutter/material.dart';

import '../features/auth/data/session_auth_repository.dart';

/// Exposes the mocked [`SessionAuthRepository`] to descendant widgets.
class TurIzimScope extends InheritedWidget {
  const TurIzimScope({required this.session, required super.child, super.key});

  final SessionAuthRepository session;

  static SessionAuthRepository of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<TurIzimScope>();
    assert(scope != null, 'TurIzimScope not found');
    return scope!.session;
  }

  @override
  bool updateShouldNotify(TurIzimScope oldWidget) =>
      oldWidget.session != session;
}
