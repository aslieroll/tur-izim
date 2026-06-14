import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:tur_izim/app/tur_izim_scope.dart';
import 'package:tur_izim/core/di/tur_izim_dependencies.dart';
import 'package:tur_izim/features/billing/domain/agency_plan.dart';
import 'package:tur_izim/features/billing/domain/agency_subscription.dart';
import 'package:tur_izim/shared/theme/tur_izim_design_tokens.dart';
import 'package:tur_izim/shared/widgets/tur_izim_primary_button.dart';
import 'package:tur_izim/shared/widgets/tur_izim_status_pill.dart';
import 'package:tur_izim/shared/widgets/tur_izim_surface_card.dart';

/// Tek bir plan kartı (Free / Pro / Growth).
///
/// [currentPlanCode] ile mevcut plan vurgulanır.
/// [plan.isFree] ise CTA gösterilmez.
class AgencyPlanCard extends StatefulWidget {
  const AgencyPlanCard({
    required this.plan,
    required this.currentPlanCode,
    super.key,
  });

  final AgencyPlan plan;
  final String currentPlanCode;

  @override
  State<AgencyPlanCard> createState() => _AgencyPlanCardState();
}

class _AgencyPlanCardState extends State<AgencyPlanCard> {
  bool _loading = false;

  bool get _isCurrent => widget.plan.planCode == widget.currentPlanCode;

  Future<void> _onCheckout() async {
    final deps = TurIzimDependencies.of(context);
    final session = TurIzimScope.of(context);
    final agencyId = session.activeAgencyId ?? '';

    setState(() => _loading = true);
    try {
      final url = await deps.billing.getCheckoutUrl(agencyId, widget.plan.planCode);
      if (!mounted) return;

      if (url != null && url.isNotEmpty) {
        final uri = Uri.tryParse(url);
        if (uri != null && uri.hasScheme) {
          final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (!ok && mounted) {
            _showSnackBar('Ödeme sayfası açılamadı. Lütfen tekrar deneyin.');
          }
        }
      } else {
        _showSnackBar('Bu plan için ödeme linki henüz tanımlanmadı.');
      }
    } catch (_) {
      if (mounted) _showSnackBar('Ödeme sayfasına ulaşılamadı. Lütfen tekrar deneyin.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPro = widget.plan.planCode == 'AGENCY_PRO';
    final isGrowth = widget.plan.planCode == 'AGENCY_GROWTH';
    final isFree = widget.plan.isFree;

    final bg = isPro
        ? TurIzimPalette.softLavender.withValues(alpha: 0.55)
        : isGrowth
            ? TurIzimPalette.successGreen.withValues(alpha: 0.10)
            : null;
    final border = isPro
        ? TurIzimPalette.royalIndigo.withValues(alpha: 0.25)
        : isGrowth
            ? TurIzimPalette.successGreen.withValues(alpha: 0.35)
            : null;

    return TurIzimSurfaceCard(
      backgroundColor: bg,
      borderColor: border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.plan.displayName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: TurIzimPalette.deepNavy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (_isCurrent)
                const TurIzimStatusPill(
                  label: 'Mevcut Plan',
                  tone: TurIzimStatusTone.accent,
                ),
              if (isGrowth && !_isCurrent)
                const TurIzimStatusPill(
                  label: 'Önerilen',
                  tone: TurIzimStatusTone.success,
                ),
            ],
          ),
          const SizedBox(height: 8),
          isFree
              ? Text(
                  'Ücretsiz',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: TurIzimPalette.deepNavy,
                    fontWeight: FontWeight.w900,
                  ),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${widget.plan.priceMonthlyTl} ₺',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: TurIzimPalette.deepNavy,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '/ ay',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: TurIzimPalette.mutedText,
                      ),
                    ),
                  ],
                ),
          const SizedBox(height: 12),
          _featureRow('${widget.plan.activeTourLimit} aktif tur ilanı', true),
          _featureRow('AI Eşleşme Asistanı', widget.plan.canUseAiMatch),
          _featureRow('Creator başvuru yönetimi', widget.plan.canManageApplicants),
          _featureRow('Manuel creator seçimi', widget.plan.canSelectCreator),
          if (widget.plan.prioritySupport)
            _featureRow('Öncelikli destek', true),
          if (!isFree && !_isCurrent) ...[
            const SizedBox(height: 16),
            TurIzimPrimaryButton(
              label: _loading ? 'Yükleniyor...' : 'Aboneliği Başlat',
              icon: _loading ? null : Icons.open_in_new_rounded,
              onPressed: _loading ? null : _onCheckout,
            ),
          ],
        ],
      ),
    );
  }

  Widget _featureRow(String text, bool enabled) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Icon(
            enabled ? Icons.check_circle_outline_rounded : Icons.remove_circle_outline_rounded,
            size: 16,
            color: enabled ? TurIzimPalette.royalIndigo : TurIzimPalette.mutedText,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: enabled ? TurIzimPalette.slateText : TurIzimPalette.mutedText,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Plan karşılaştırma bölümü: mevcut durum + Free / Pro / Growth kartları.
///
/// [subscription] dışarıdan (AgencyBoardScreen) aktarılır.
/// [plans] backend'den yüklenir; hata durumunda statik liste kullanılır.
class SubscriptionPlansSection extends StatefulWidget {
  const SubscriptionPlansSection({
    required this.subscription,
    super.key,
  });

  final AgencySubscription subscription;

  @override
  State<SubscriptionPlansSection> createState() => _SubscriptionPlansSectionState();
}

class _SubscriptionPlansSectionState extends State<SubscriptionPlansSection> {
  Future<List<AgencyPlan>>? _plansFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _plansFuture ??= TurIzimDependencies.of(context).billing.getPlans();
  }

  String get _currentPlanCode {
    return switch (widget.subscription.planCode) {
      AgencySubscriptionPlanCode.agencyPro => 'AGENCY_PRO',
      AgencySubscriptionPlanCode.agencyGrowth => 'AGENCY_GROWTH',
      _ => 'FREE',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        Text(
          'Abonelik Planları',
          style: theme.textTheme.titleMedium?.copyWith(
            color: TurIzimPalette.deepNavy,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Acentenize uygun planı seçin. Creator başvuruları her planda ücretsizdir.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: TurIzimPalette.mutedText,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<AgencyPlan>>(
          future: _plansFuture,
          builder: (context, snap) {
            final plans = snap.data ?? AgencyPlan.staticPlans;
            return Column(
              children: plans
                  .map(
                    (plan) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AgencyPlanCard(
                        plan: plan,
                        currentPlanCode: _currentPlanCode,
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}
