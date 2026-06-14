import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tur_izim/app/router.dart';
import 'package:tur_izim/app/tur_izim_scope.dart';
import 'package:tur_izim/core/constants/app_constants.dart';
import 'package:tur_izim/core/errors/user_error_message.dart';
import 'package:tur_izim/shared/models/user_role.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String? _emailLabelError(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return 'E-posta gerekli.';
    if (!t.contains('@')) return 'Geçerli bir e-posta girin.';
    return null;
  }

  String? _passwordLabelError(String? v) {
    if ((v ?? '').isEmpty) return 'Şifre gerekli.';
    return null;
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final session = TurIzimScope.of(context);
    setState(() => _busy = true);
    try {
      await session.signInWithPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
      if (!mounted) return;
      final r = session.currentRole;
      if (r == null) return;
      context.go(_homeFor(r));
    } on Object catch (e) {
      if (mounted) {
        setState(() => _error = userFacingErrorMessage(e));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  static String _homeFor(UserRole role) => switch (role) {
        UserRole.creator => AppRoutes.creatorHome,
        UserRole.agency => AppRoutes.agencyHome,
        UserRole.admin => AppRoutes.adminHome,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giriş yap'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _busy ? null : () => context.go(AppRoutes.welcome),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.pageHorizontalMargin),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Tur İzim hesabınla giriş yap',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.username],
                decoration: const InputDecoration(
                  labelText: 'E-posta',
                  border: OutlineInputBorder(),
                ),
                validator: _emailLabelError,
                enabled: !_busy,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _password,
                obscureText: _obscure,
                autofillHints: const [AutofillHints.password],
                decoration: InputDecoration(
                  labelText: 'Şifre',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: _busy
                        ? null
                        : () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: _passwordLabelError,
                enabled: !_busy,
                onFieldSubmitted: (_) => _submit(),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _busy ? null : _submit,
                child: _busy
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Giriş'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _busy
                    ? null
                    : () => context.push(AppRoutes.registerCreator),
                child: const Text('Üretici kaydı'),
              ),
              TextButton(
                onPressed: _busy
                    ? null
                    : () => context.push(AppRoutes.registerAgency),
                child: const Text('Acente kaydı'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
