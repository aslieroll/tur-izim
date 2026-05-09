import 'package:flutter/material.dart';

class ApplicantSortDisclaimer extends StatelessWidget {
  const ApplicantSortDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        'Aday Uygunluk Endeksi yalnızca sıralama ve karar desteği içindir; '
        'otomatik atama veya önerilen seçim yoktur. Nihai seçim her zaman '
        'acentededir.',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
