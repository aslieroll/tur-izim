import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tur_izim/app/router.dart';
import 'package:tur_izim/app/tur_izim_scope.dart';
import 'package:tur_izim/core/di/tur_izim_dependencies.dart';
import 'package:tur_izim/core/errors/app_exception.dart';
import 'package:tur_izim/shared/models/application_commitment.dart';
import 'package:tur_izim/shared/widgets/mandatory_application_checkboxes.dart';
import 'package:tur_izim/shared/widgets/publication_commitment_info_card.dart';

class CreatorDepositAckScreen extends StatefulWidget {
  const CreatorDepositAckScreen({required this.assignmentId, super.key});

  final String assignmentId;

  @override
  State<CreatorDepositAckScreen> createState() =>
      _CreatorDepositAckScreenState();
}

class _CreatorDepositAckScreenState extends State<CreatorDepositAckScreen> {
  ApplicationCommitment _commitment = const ApplicationCommitment(
    acceptedPublicationCommitment: false,
    acceptedContentUsagePermission: false,
    acceptedTourPriceClaimCondition: false,
  );

  bool _busy = false;

  Future<void> _submit() async {
    final deps = TurIzimDependencies.of(context);
    final session = TurIzimScope.of(context);

    if (!_commitment.isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Taahhüt kutularının tamamını işaretlemelisiniz.'),
        ),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      await deps.assignments.creatorConfirmDeposit(
        assignmentId: widget.assignmentId,
        creatorId: session.activeCreatorId!,
        commitment: _commitment,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mock depozito bloke sürecine geçildi.')),
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
      appBar: AppBar(title: const Text('Son taahhüt onayı')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const PublicationCommitmentInfoCard(),
          const SizedBox(height: 16),
          MandatoryApplicationCheckboxes(
            onChanged: (c) => setState(() => _commitment = c),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _busy ? null : _submit,
            child: _busy
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Onaylıyorum ve mock sürecini ilerlet'),
          ),
        ],
      ),
    );
  }
}
