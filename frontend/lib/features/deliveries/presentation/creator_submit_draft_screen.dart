import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tur_izim/app/router.dart';
import 'package:tur_izim/app/tur_izim_scope.dart';
import 'package:tur_izim/core/di/tur_izim_dependencies.dart';
import 'package:tur_izim/core/errors/app_exception.dart';
import 'package:tur_izim/shared/widgets/url_field_with_open.dart';

class CreatorSubmitDraftScreen extends StatefulWidget {
  const CreatorSubmitDraftScreen({required this.assignmentId, super.key});

  final String assignmentId;

  @override
  State<CreatorSubmitDraftScreen> createState() =>
      _CreatorSubmitDraftScreenState();
}

class _CreatorSubmitDraftScreenState extends State<CreatorSubmitDraftScreen> {
  final _urlCtrl = TextEditingController();

  bool _busy = false;

  @override
  void dispose() {
    _urlCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final url = _urlCtrl.text.trim();
    if (!(url.startsWith('http://') || url.startsWith('https://'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçerli bir https bağlantısı girin.')),
      );
      return;
    }

    final deps = TurIzimDependencies.of(context);
    final session = TurIzimScope.of(context);

    setState(() => _busy = true);
    try {
      await deps.deliveries.submitDraftUrl(
        assignmentId: widget.assignmentId,
        creatorId: session.activeCreatorId!,
        url: url,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Taslak URL gönderildi.')));
      context.go(AppRoutes.creatorAssignment(widget.assignmentId));
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Taslak teslim bağlantısı')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Dosya yükleme yoktur — yalnızca güvenilir bir bağlantı paylaşılır '
              '(ör. Drive, WeTransfer ile paylaşılan URL).',
            ),
            const SizedBox(height: 16),
            UrlFieldWithOpen(
              controller: _urlCtrl,
              validator: (v) =>
                  v == null || v.trim().length < 8 ? 'Bağlantı gerekli' : null,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _busy ? null : _submit,
              child: _busy
                  ? const CircularProgressIndicator()
                  : const Text('Gönder'),
            ),
          ],
        ),
      ),
    );
  }
}
