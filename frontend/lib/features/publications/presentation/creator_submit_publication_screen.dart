import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tur_izim/app/router.dart';
import 'package:tur_izim/app/tur_izim_scope.dart';
import 'package:tur_izim/core/di/tur_izim_dependencies.dart';
import 'package:tur_izim/core/errors/app_exception.dart';
import 'package:tur_izim/shared/widgets/publication_commitment_info_card.dart';
import 'package:tur_izim/shared/widgets/url_field_with_open.dart';

class CreatorSubmitPublicationScreen extends StatefulWidget {
  const CreatorSubmitPublicationScreen({required this.assignmentId, super.key});

  final String assignmentId;

  @override
  State<CreatorSubmitPublicationScreen> createState() =>
      _CreatorSubmitPublicationScreenState();
}

class _CreatorSubmitPublicationScreenState
    extends State<CreatorSubmitPublicationScreen> {
  final _ctrl = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final url = _ctrl.text.trim();
    if (!(url.startsWith('http://') || url.startsWith('https://'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yayın gönderisi URL’sini girin.')),
      );
      return;
    }
    final deps = TurIzimDependencies.of(context);
    final session = TurIzimScope.of(context);

    setState(() => _busy = true);
    try {
      await deps.publications.submitPublicationUrl(
        assignmentId: widget.assignmentId,
        creatorId: session.activeCreatorId!,
        publishedUrl: url,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yayın bağlantısı iletildi (mock).')),
      );
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
      appBar: AppBar(title: const Text('Yayın bildirimi')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const PublicationCommitmentInfoCard(),
          const SizedBox(height: 24),
          UrlFieldWithOpen(
            controller: _ctrl,
            label: 'Yayındaki gönderi bağlantısı',
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _busy ? null : _submit,
            child: _busy
                ? const CircularProgressIndicator()
                : const Text('İlet'),
          ),
        ],
      ),
    );
  }
}
