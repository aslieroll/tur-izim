import 'package:flutter/material.dart';

import 'package:tur_izim/features/ai_match/domain/ai_match_repository.dart';
import 'package:tur_izim/shared/theme/tur_izim_design_tokens.dart';
import 'package:tur_izim/shared/widgets/tur_izim_status_pill.dart';

/// AI Eşleşme Asistanı kartı — yükleme / hata / sonuç durumları.
///
/// [future] çağıran ekranda **başvuru başına bir kez** oluşturulmalı ve
/// cache'lenmelidir; bu widget render döngüsünde yeni istek başlatmaz.
class AiMatchScoreCard extends StatelessWidget {
  const AiMatchScoreCard({required this.future, this.onRetry, super.key});

  final Future<AiMatchResult> future;

  /// Hata durumunda cache'i temizleyip yeniden dener.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: TurIzimPalette.softLavender.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(TurIzimDesignTokens.radiusMedium),
        border: Border.all(
          color: TurIzimPalette.royalIndigo.withValues(alpha: 0.14),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: FutureBuilder<AiMatchResult>(
          future: future,
          builder: (context, snap) {
            if (snap.hasError) return _ErrorBody(onRetry: onRetry);
            if (!snap.hasData) return const _LoadingBody();
            return _ResultBody(result: snap.data!);
          },
        ),
      ),
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 10),
        Text(
          'AI skoru hesaplanıyor...',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.cloud_off_rounded,
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'AI eşleşme skoru şu anda alınamadı.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        if (onRetry != null)
          TextButton(onPressed: onRetry, child: const Text('Yeniden dene')),
      ],
    );
  }
}

class _ResultBody extends StatelessWidget {
  const _ResultBody({required this.result});

  final AiMatchResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.auto_awesome_rounded,
              size: 18,
              color: TurIzimPalette.royalIndigo,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'AI Eşleşme Asistanı',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: TurIzimPalette.deepNavy,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            TurIzimStatusPill(
              tone: TurIzimStatusTone.info,
              icon: Icons.speed_rounded,
              label: 'Uygunluk: ${result.fitnessScore}/100',
            ),
            TurIzimStatusPill(
              tone: _riskTone(result.riskLevel),
              icon: Icons.shield_outlined,
              label: _riskLabel(result.riskLevel),
            ),
          ],
        ),
        if (result.aiSummary.trim().isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            result.aiSummary,
            style: theme.textTheme.bodySmall?.copyWith(height: 1.45),
          ),
        ],
        if (result.fallbackUsed) ...[
          const SizedBox(height: 6),
          Text(
            'Özet deterministik kuraldan üretildi (AI yanıtı alınamadı).',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        const SizedBox(height: 6),
        Text(
          'Bu skor karar destek amaçlıdır; nihai seçim acenteye aittir.',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  static TurIzimStatusTone _riskTone(AiMatchRiskLevel risk) {
    return switch (risk) {
      AiMatchRiskLevel.low => TurIzimStatusTone.success,
      AiMatchRiskLevel.medium => TurIzimStatusTone.warning,
      AiMatchRiskLevel.high => TurIzimStatusTone.danger,
    };
  }

  static String _riskLabel(AiMatchRiskLevel risk) {
    return switch (risk) {
      AiMatchRiskLevel.low => 'Düşük risk',
      AiMatchRiskLevel.medium => 'Orta risk',
      AiMatchRiskLevel.high => 'Yüksek risk',
    };
  }
}
