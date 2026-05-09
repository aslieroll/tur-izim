import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tur_izim/app/router.dart';
import 'package:tur_izim/app/tur_izim_scope.dart';
import 'package:tur_izim/core/constants/app_constants.dart';
import 'package:tur_izim/core/di/tur_izim_dependencies.dart';
import 'package:tur_izim/core/errors/app_exception.dart';
import 'package:tur_izim/shared/models/application_commitment.dart';
import 'package:tur_izim/shared/models/assignment_detail.dart';
import 'package:tur_izim/shared/presentation/status_label_turkish.dart';
import 'package:tur_izim/shared/presentation/tour_display_format.dart';
import 'package:tur_izim/shared/presentation/turkish_lira_format.dart';
import 'package:tur_izim/shared/theme/tur_izim_design_tokens.dart';
import 'package:tur_izim/shared/widgets/mandatory_application_checkboxes.dart';
import 'package:tur_izim/shared/widgets/publication_commitment_info_card.dart';
import 'package:tur_izim/shared/widgets/tur_izim_info_banner.dart';
import 'package:tur_izim/shared/widgets/tur_izim_primary_button.dart';
import 'package:tur_izim/shared/widgets/tur_izim_section_header.dart';
import 'package:tur_izim/shared/widgets/tur_izim_status_pill.dart';
import 'package:tur_izim/shared/widgets/tur_izim_surface_card.dart';

class CreatorDepositAckScreen extends StatefulWidget {
  const CreatorDepositAckScreen({required this.assignmentId, super.key});

  final String assignmentId;

  @override
  State<CreatorDepositAckScreen> createState() =>
      _CreatorDepositAckScreenState();
}

class _CreatorDepositAckScreenState extends State<CreatorDepositAckScreen> {
  Future<AssignmentDetail?>? _detailFuture;

  ApplicationCommitment _commitment = const ApplicationCommitment(
    acceptedPublicationCommitment: false,
    acceptedContentUsagePermission: false,
    acceptedTourPriceClaimCondition: false,
  );

  bool _busy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _detailFuture ??= _loadDetail();
  }

  Future<AssignmentDetail?> _loadDetail() {
    final deps = TurIzimDependencies.of(context);
    final session = TurIzimScope.of(context);
    return deps.assignments.loadAssignmentDetail(
      assignmentId: widget.assignmentId,
      viewerCreatorId: session.activeCreatorId!,
      viewerAgencyId: null,
    );
  }

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
      appBar: AppBar(title: const Text('Depozito Onayı')),
      body: FutureBuilder<AssignmentDetail?>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final detail = snapshot.data;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.pageHorizontalMargin,
              20,
              AppConstants.pageHorizontalMargin,
              32,
            ),
            children: [
              _TrustHeroCard(detail: detail),
              if (detail != null) ...[
                const SizedBox(height: 20),
                _DepositSummaryCard(detail: detail),
              ],
              const SizedBox(height: 20),
              const PublicationCommitmentInfoCard(),
              const SizedBox(height: 20),
              _CommitmentChecklistCard(
                onChanged: (commitment) =>
                    setState(() => _commitment = commitment),
              ),
              const SizedBox(height: 20),
              _ConfirmCtaCard(busy: _busy, onSubmit: _submit),
            ],
          );
        },
      ),
    );
  }
}

class _TrustHeroCard extends StatelessWidget {
  const _TrustHeroCard({required this.detail});

  final AssignmentDetail? detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          TurIzimDesignTokens.radiusExtraLarge,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TurIzimPalette.softSkyBlue.withValues(alpha: 0.86),
            TurIzimPalette.softLavender.withValues(alpha: 0.88),
            Colors.white.withValues(alpha: 0.96),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
        boxShadow: TurIzimDesignTokens.premiumShadow(),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -34,
            top: -34,
            child: _DecorativeCircle(
              size: 136,
              color: TurIzimPalette.royalIndigo.withValues(alpha: 0.10),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -34,
            child: _DecorativeCircle(
              size: 104,
              color: TurIzimPalette.softCoral.withValues(alpha: 0.12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(TurIzimDesignTokens.cardPaddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TurIzimStatusPill(
                  label: 'Mock güvence',
                  tone: TurIzimStatusTone.accent,
                  icon: Icons.verified_user_outlined,
                ),
                const SizedBox(height: 16),
                Text(
                  'Depozito Onayı',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: TurIzimPalette.deepNavy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bu adım MVP’de mock güvence sürecidir; kart formu '
                  'gösterilmez ve onaylı para hareketine geçmez.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: TurIzimPalette.deepNavy.withValues(alpha: 0.70),
                    height: 1.5,
                  ),
                ),
                if (detail != null) ...[
                  const SizedBox(height: 18),
                  _HeroInfoLine(
                    icon: Icons.travel_explore_rounded,
                    label: detail!.tour.title,
                  ),
                  const SizedBox(height: 8),
                  _HeroInfoLine(
                    icon: Icons.route_rounded,
                    label:
                        'Çıkış: ${detail!.tour.departureCity} · '
                              'Rota: ${tourRouteOverviewLineTurkish(detail!.tour)}',
                  ),
                  const SizedBox(height: 8),
                  _HeroInfoLine(
                    icon: Icons.calendar_month_outlined,
                    label:
                        '${formatTourCalendarDate(detail!.tour.startsAt)} – ${formatTourCalendarDate(detail!.tour.endsAt)}',
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DepositSummaryCard extends StatelessWidget {
  const _DepositSummaryCard({required this.detail});

  final AssignmentDetail detail;

  @override
  Widget build(BuildContext context) {
    final deposit = detail.deposit;
    final depositAmount =
        deposit?.amountSnapshot ?? detail.tour.expectedDepositAmount;

    return TurIzimSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TurIzimSectionHeader(
            overline: 'Depozito özeti',
            title: 'Güvence bilgileri',
            subtitle:
                'Bu alan yalnızca mock durum bilgisidir; tahsilat adımı değildir.',
            action: deposit == null
                ? null
                : TurIzimStatusPill(
                    label: mockDepositStatusLabelTurkish(deposit.status),
                    tone: TurIzimStatusTone.warning,
                  ),
          ),
          const SizedBox(height: 16),
          _ValueRow(
            label: 'Beklenen depozito',
            value: formatTurkishLiraAmount(
              depositAmount,
              currencyCode: detail.tour.currency,
            ),
          ),
          const SizedBox(height: 10),
          _ValueRow(
            label: 'Normal satış değeri',
            value: formatTurkishLiraAmount(
              detail.tour.normalSalesPrice,
              currencyCode: detail.tour.currency,
            ),
          ),
          const SizedBox(height: 14),
          const TurIzimInfoBanner(
            title: 'Tahsilat ekranı değildir',
            message:
                'MVP’de gerçek para hareketleri yürütülmez. Onay sonrası '
                'mevcut mock akışında PENDING durumu HELD durumuna geçebilir.',
            tone: TurIzimStatusTone.info,
            icon: Icons.lock_outline_rounded,
          ),
        ],
      ),
    );
  }
}

class _CommitmentChecklistCard extends StatelessWidget {
  const _CommitmentChecklistCard({required this.onChanged});

  final CommitmentChanged onChanged;

  @override
  Widget build(BuildContext context) {
    return TurIzimSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TurIzimSectionHeader(
            overline: 'Son taahhüt',
            title: 'Onay kutuları',
            subtitle:
                'Kutular ön seçili değildir. Üç koşul da manuel işaretlenmeden mock depozito süreci ilerletilemez.',
          ),
          const SizedBox(height: 12),
          MandatoryApplicationCheckboxes(onChanged: onChanged),
        ],
      ),
    );
  }
}

class _ConfirmCtaCard extends StatelessWidget {
  const _ConfirmCtaCard({required this.busy, required this.onSubmit});

  final bool busy;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return TurIzimSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TurIzimSectionHeader(
            overline: 'Son adım',
            title: 'Mock depozitoyu onayla',
            subtitle:
                'Onaydan sonra mevcut assignment/deposit mock geçişleri çalışır; business logic değiştirilmez.',
          ),
          const SizedBox(height: 16),
          TurIzimPrimaryButton(
            label: busy ? 'Kaydediliyor...' : 'Depozitoyu Onayla',
            icon: Icons.arrow_forward_rounded,
            onPressed: busy ? null : onSubmit,
          ),
        ],
      ),
    );
  }
}

class _HeroInfoLine extends StatelessWidget {
  const _HeroInfoLine({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 18, color: TurIzimPalette.royalIndigo),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: TurIzimPalette.deepNavy.withValues(alpha: 0.76),
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: TurIzimPalette.softLavender.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(TurIzimDesignTokens.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                color: TurIzimPalette.deepNavy,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  const _DecorativeCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
