import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tur_izim/app/router.dart';
import 'package:tur_izim/app/tur_izim_scope.dart';
import 'package:tur_izim/core/constants/app_constants.dart';
import 'package:tur_izim/core/errors/user_error_message.dart';
import 'package:tur_izim/features/auth/domain/auth_dtos.dart';

class RegisterCreatorScreen extends StatefulWidget {
  const RegisterCreatorScreen({super.key});

  @override
  State<RegisterCreatorScreen> createState() => _RegisterCreatorScreenState();
}

class _RegisterCreatorScreenState extends State<RegisterCreatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _university = TextEditingController();
  final _city = TextEditingController();
  String _passportType = PassportTypeApi.turkishOrdinary;
  bool _hasValidPassport = true;
  bool _schengen = false;
  bool _us = false;
  bool _uk = false;
  bool _otherVisa = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _password.dispose();
    _university.dispose();
    _city.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final session = TurIzimScope.of(context);
    setState(() => _busy = true);
    try {
      await session.registerCreatorAccount(
        RegisterCreatorRequest(
          fullName: _fullName.text.trim(),
          email: _email.text.trim(),
          password: _password.text,
          universityName: _university.text.trim(),
          city: _city.text.trim(),
          passportType: _passportType,
          hasValidPassport: _hasValidPassport,
          hasSchengenVisa: _schengen,
          hasUsVisa: _us,
          hasUkVisa: _uk,
          hasOtherValidVisa: _otherVisa,
        ),
      );
      if (!mounted) return;
      context.go(AppRoutes.creatorHome);
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
        title: const Text('Üretici kaydı'),
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
                'Kampüs üreticisi olarak kayıt ol',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fullName,
                decoration: const InputDecoration(
                  labelText: 'Ad soyad',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Gerekli.' : null,
                enabled: !_busy,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-posta',
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
                controller: _university,
                decoration: const InputDecoration(
                  labelText: 'Üniversite adı',
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
              const SizedBox(height: 10),
              InputDecorator(
                isEmpty: false,
                decoration: const InputDecoration(
                  labelText: 'Pasaport türü (beyan)',
                  border: OutlineInputBorder(),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _passportType,
                    items: [
                      for (final e in PassportTypeApi.pickerEntries)
                        DropdownMenuItem(value: e.$1, child: Text(e.$2)),
                    ],
                    onChanged: _busy
                        ? null
                        : (v) =>
                            setState(() => _passportType = v ?? _passportType),
                  ),
                ),
              ),
              SwitchListTile(
                title: const Text('Geçerli pasaportum var'),
                value: _hasValidPassport,
                onChanged: _busy
                    ? null
                    : (v) => setState(() => _hasValidPassport = v),
              ),
              CheckboxListTile(
                title: const Text('Schengen vizesi'),
                value: _schengen,
                onChanged: _busy ? null : (v) => setState(() => _schengen = v ?? false),
              ),
              CheckboxListTile(
                title: const Text('ABD vizesi'),
                value: _us,
                onChanged: _busy ? null : (v) => setState(() => _us = v ?? false),
              ),
              CheckboxListTile(
                title: const Text('UK vizesi'),
                value: _uk,
                onChanged: _busy ? null : (v) => setState(() => _uk = v ?? false),
              ),
              CheckboxListTile(
                title: const Text('Başka geçerli vize'),
                value: _otherVisa,
                onChanged: _busy
                    ? null
                    : (v) => setState(() => _otherVisa = v ?? false),
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
