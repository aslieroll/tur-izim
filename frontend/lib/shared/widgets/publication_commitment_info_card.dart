import 'package:flutter/material.dart';

/// Statik uyarı blokları — hukuki metin ileride eklenecek.
class PublicationCommitmentInfoCard extends StatelessWidget {
  const PublicationCommitmentInfoCard({super.key});

  static const List<String> _bullets = <String>[
    'Onaylanan içeriği kişisel hesabınızda yayınlayacaksınız ve gönderiyi '
        'en az 30 gün boyunca herkese açık tutacaksınız.',
    'Süresi dolmadan silme, gizleme veya erişilemez kılma hallerinde acente ile '
        'aranızdaki koşullar kapsamında talep oluşabileceği kaydedilir '
        '(MVP’de otomatik işlem veya crawler yoktur).',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: scheme.primary),
                const SizedBox(width: 10),
                Text(
                  '30 günlük yayın taahhüdü özeti',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Aşağıdaki uyarı kutularına işaretlediğinizde bu koşulları tekrar '
              'doğrulamış olursunuz.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            ..._bullets.map(
              (b) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('•  '),
                    Expanded(child: Text(b, style: theme.textTheme.bodyMedium)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
