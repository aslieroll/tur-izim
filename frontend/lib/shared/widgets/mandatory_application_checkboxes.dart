import 'package:flutter/material.dart';

import '../models/application_commitment.dart';

typedef CommitmentChanged = void Function(ApplicationCommitment value);

class MandatoryApplicationCheckboxes extends StatefulWidget {
  const MandatoryApplicationCheckboxes({super.key, required this.onChanged});

  final CommitmentChanged onChanged;

  @override
  State<MandatoryApplicationCheckboxes> createState() =>
      _MandatoryApplicationCheckboxesState();
}

class _MandatoryApplicationCheckboxesState
    extends State<MandatoryApplicationCheckboxes> {
  bool _publish = false;
  bool _usage = false;
  bool _pricing = false;

  void _emit() {
    widget.onChanged(
      ApplicationCommitment(
        acceptedPublicationCommitment: _publish,
        acceptedContentUsagePermission: _usage,
        acceptedTourPriceClaimCondition: _pricing,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CheckboxListTile(
          title: const Text(
            '30 günlük herkese açık yayın taahhüdünü kabul ediyorum.',
          ),
          subtitle: const Text(
            'Gönderiyi en az 30 gün erişilebilir tutma yükümlülüğü.',
          ),
          value: _publish,
          onChanged: (v) {
            setState(() => _publish = v ?? false);
            _emit();
          },
          controlAffinity: ListTileControlAffinity.leading,
        ),
        CheckboxListTile(
          title: const Text(
            'Acentenin kendi sosyal ve tanıtım kanallarında içeriği kullanma '
            'izni veriyorum.',
          ),
          value: _usage,
          onChanged: (v) {
            setState(() => _usage = v ?? false);
            _emit();
          },
          controlAffinity: ListTileControlAffinity.leading,
        ),
        CheckboxListTile(
          title: const Text(
            'Şartların ihlalinde tur bedelinin tamamına yönelik taleplerin '
            'kayıt altına alınabileceğini anlıyorum (MVP’de otomatik tahsil '
            'yoktur).',
          ),
          value: _pricing,
          onChanged: (v) {
            setState(() => _pricing = v ?? false);
            _emit();
          },
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ],
    );
  }
}
