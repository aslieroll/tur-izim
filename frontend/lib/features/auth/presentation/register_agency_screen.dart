import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tur_izim/app/router.dart';
import 'package:tur_izim/app/tur_izim_scope.dart';
import 'package:tur_izim/core/constants/app_constants.dart';
import 'package:tur_izim/core/errors/user_error_message.dart';
import 'package:tur_izim/features/auth/domain/auth_dtos.dart';

class RegisterAgencyScreen extends StatefulWidget {
  const RegisterAgencyScreen({super.key});

  @override
  State<RegisterAgencyScreen> createState() => _RegisterAgencyScreenState();
}

class _RegisterAgencyScreenState extends State<RegisterAgencyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _contactEmail = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  final _city = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _contactEmail.dispose();
    _password.dispose();
    _phone.dispose();
    _city.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final session = TurIzimScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await session.registerAgencyAccount(
        RegisterAgencyRequest(
          name: _name.text.trim(),
          contactEmail: _contactEmail.text.trim(),
          password: _password.text,
          phone: _phone.text.trim(),
          city: _city.text.trim(),
        ),
      );
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Kayıt alındı. Acente hesabınız yönetici onayına düştü; '
            'onay sonrası tam işlemler açılır. Şimdilik oturumunuz açık.',
          ),
        ),
      );
      context.go(AppRoutes.agencyHome);
    } on Object catch (e) {
      if (mounted) setState(() => _error = userFacingErrorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Acente kaydı'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _busy ? null : () => context.pop(),
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
                'Yerel tur acentesi olarak kayıt',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Acente adı',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Gerekli.' : null,
                enabled: !_busy,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _contactEmail,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'İletişim e-postası (giriş için kullanılır)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final t = v?.trim() ?? '';
                  if (t.isEmpty) return 'Gerekli.';
                  if (!t.contains('@')) return 'Geçerli e-posta girin.';
                  return null;
                },
                enabled: !_busy,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Şifre (en az 8 karakter)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if ((v ?? '').length < 8) return 'En az 8 karakter.';
                  return null;
                },
                enabled: !_busy,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Telefon',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Gerekli.' : null,
                enabled: !_busy,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _city,
                decoration: const InputDecoration(
                  labelText: 'Şehir',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Gerekli.' : null,
                enabled: !_busy,
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
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
                    : const Text('Kayıt ol ve devam et'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
