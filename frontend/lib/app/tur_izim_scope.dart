import 'package:flutter/widgets.dart';

import '../features/auth/data/session_auth_repository.dart';

/// [SessionAuthRepository] değişince (JWT / demo) alt ağaç yenilenir.
class TurIzimScope extends InheritedNotifier<SessionAuthRepository> {
  // ignore: prefer_const_constructors_in_immutables — [SessionAuthRepository] const değil
  TurIzimScope({
    super.key,
    required SessionAuthRepository session,
    required super.child,
  }) : super(notifier: session);

  static SessionAuthRepository of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<TurIzimScope>();
    assert(scope != null, 'TurIzimScope not found');
    return scope!.notifier!;
  }
}
