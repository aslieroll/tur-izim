import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tur_izim/app/router.dart';
import 'package:tur_izim/app/tur_izim_scope.dart';
import 'package:tur_izim/core/api/api_exception.dart';
import 'package:tur_izim/core/constants/app_constants.dart';
import 'package:tur_izim/core/di/tur_izim_dependencies.dart';
import 'package:tur_izim/core/errors/app_exception.dart';
import 'package:tur_izim/shared/models/application_commitment.dart';
import 'package:tur_izim/shared/models/tour_detail.dart';
import 'package:tur_izim/shared/models/tour_scope.dart';
import 'package:tur_izim/shared/presentation/status_label_turkish.dart';
import 'package:tur_izim/shared/presentation/travel_eligibility_labels_turkish.dart';
import 'package:tur_izim/shared/presentation/tour_display_format.dart';
import 'package:tur_izim/shared/presentation/turkish_lira_format.dart';
import 'package:tur_izim/shared/theme/tur_izim_design_tokens.dart';
import 'package:tur_izim/shared/widgets/international_mandatory_requirements_card.dart';
import 'package:tur_izim/shared/widgets/mandatory_application_checkboxes.dart';
import 'package:tur_izim/shared/widgets/publication_commitment_info_card.dart';
import 'package:tur_izim/shared/widgets/tur_izim_info_banner.dart';
import 'package:tur_izim/shared/widgets/tur_izim_section_header.dart';
import 'package:tur_izim/shared/widgets/tur_izim_status_pill.dart';
import 'package:tur_izim/shared/widgets/tur_izim_surface_card.dart';

/// Mock başvuru gönderimi — kayıt yalnızca `MockTurIzimStore` içinde (Aşama 2.4).
class CreatorApplicationFormScreen extends StatefulWidget {
  const CreatorApplicationFormScreen({required this.tourId, super.key});

  final String tourId;

  @override
  State<CreatorApplicationFormScreen> createState() =>
      _CreatorApplicationFormScreenState();
}

class _CreatorApplicationFormScreenState
    extends State<CreatorApplicationFormScreen> {
  final _messageCtrl = TextEditingController();
  ApplicationCommitment _commitment = const ApplicationCommitment(
    acceptedPublicationCommitment: false,
    acceptedContentUsagePermission: false,
    acceptedTourPriceClaimCondition: false,
  );

  Future<({TourDetail? tour, bool duplicate, bool eligible})>? _bundle;
  bool _submitting = false;

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bundle ??= _loadBundle();
  }

  Future<({TourDetail? tour, bool duplicate, bool eligible})>
  _loadBundle() async {
    final deps = TurIzimDependencies.of(context);
    final session = TurIzimScope.of(context);
    final creatorId = session.activeCreatorId!;
    final tour = await deps.tours.fetchTourDetail(widget.tourId);
    if (tour == null) {
      return (tour: null, duplicate: false, eligible: false);
    }
    final dup = await deps.tours.hasCreatorApplied(
      tourId: widget.tourId,
      creatorId: creatorId,
    );
    final eligible = await deps.tours.isCreatorEligibleForTour(
      creatorId: creatorId,
      tourId: widget.tourId,
    );
    return (tour: tour, duplicate: dup, eligible: eligible);
  }

  Future<void> _submit() async {
    final deps = TurIzimDependencies.of(context);
    final session = TurIzimScope.of(context);
    if (!_commitment.isComplete) return;

    setState(() => _submitting = true);
    try {
      await deps.applications.submitApplication(
        creatorId: session.activeCreatorId!,
        tourId: widget.tourId,
        commitment: _commitment,
        message: _messageCtrl.text.trim().isEmpty
            ? null
            : _messageCtrl.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Başvurunuz kaydedildi.')),
      );
      context.go(AppRoutes.creatorApplications);
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.userMessage)),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tur başvurusu')),
      body: FutureBuilder<({TourDetail? tour, bool duplicate, bool eligible})>(
        future: _bundle,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting ||
              snap.data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final tour = snap.data!.tour;
          final duplicate = snap.data!.duplicate;
          final eligible = snap.data!.eligible;
          if (tour == null) {
            return const Center(child: Text('Tur bulunamadı.'));
          }

          final agencyLine = agencyDisplayLineWithCityTurkish(tour);
          final blocked = duplicate || !tour.isOpenForApplications || !eligible;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.pageHorizontalMargin,
              20,
              AppConstants.pageHorizontalMargin,
              32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ApplicationIntroCard(blocked: blocked),
                const SizedBox(height: 20),
                _TourSummaryCard(tour: tour, agencyLine: agencyLine),
                if (tour.tourScope == TourScope.international) ...[
                  const SizedBox(height: 20),
                  InternationalMandatoryRequirementsCard(tour: tour),
                ],
                const SizedBox(height: 20),
                const TurIzimInfoBanner(
                  title: 'Seyahat ürünü sunumu için değildir',
                  message:
                      'Bu başvuru acentenin manuel değerlendirmesine gönderilir. Sistem otomatik seçim veya rastgele atama yapmaz.',
                  tone: TurIzimStatusTone.info,
                  icon: Icons.info_outline_rounded,
                ),
                const SizedBox(height: 16),
                _BlockedStateBanner(
                  duplicate: duplicate,
                  eligible: eligible,
                  isInternational: tour.tourScope == TourScope.international,
                  isOpenForApplications: tour.isOpenForApplications,
                ),
                if (blocked) const SizedBox(height: 16),
                const PublicationCommitmentInfoCard(),
                const SizedBox(height: 20),
                _CommitmentChecklistCard(
                  blocked: blocked,
                  onChanged: (value) => setState(() => _commitment = value),
                ),
                const SizedBox(height: 20),
                TurIzimSurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TurIzimSectionHeader(
                        overline: 'Opsiyonel',
                        title: 'Başvuru mesajı',
                        subtitle:
                            'Acenteye kısa bir not bırakabilirsiniz. Bu alan AUE hesabına dahil değildir.',
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _messageCtrl,
                        enabled: !blocked,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Mesajınız (opsiyonel)',
                          hintText:
                              'Neden bu tur için uygun olduğunuzu kısaca anlatın.',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _SubmitCard(
                  submitting: _submitting,
                  blocked: blocked,
                  commitmentComplete: _commitment.isComplete,
                  onSubmit: _submit,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ApplicationIntroCard extends StatelessWidget {
  const _ApplicationIntroCard({required this.blocked});

  final bool blocked;

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
            TurIzimPalette.sandCream.withValues(alpha: 0.92),
            TurIzimPalette.softSkyBlue.withValues(alpha: 0.66),
            TurIzimPalette.softLavender.withValues(alpha: 0.84),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
        boxShadow: TurIzimDesignTokens.premiumShadow(),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -32,
            top: -36,
            child: _DecorativeCircle(
              size: 132,
              color: TurIzimPalette.royalIndigo.withValues(alpha: 0.10),
            ),
          ),
          Positioned(
            left: -28,
            bottom: -32,
            child: _DecorativeCircle(
              size: 98,
              color: TurIzimPalette.softCoral.withValues(alpha: 0.12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(TurIzimDesignTokens.cardPaddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TurIzimStatusPill(
                  label: blocked ? 'Kontrol gerekli' : 'Güvenli başvuru adımı',
                  tone: blocked
                      ? TurIzimStatusTone.warning
                      : TurIzimStatusTone.accent,
                  icon: blocked
                      ? Icons.info_outline_rounded
                      : Icons.verified_user_outlined,
                ),
                const SizedBox(height: 16),
                Text(
                  'Tur başvurusu',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: TurIzimPalette.deepNavy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bu form, başvurunuzu acentenin manuel değerlendirmesine iletir. Üç zorunlu taahhüt işaretlenmeden başvuru gönderilemez.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: TurIzimPalette.deepNavy.withValues(alpha: 0.70),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TourSummaryCard extends StatelessWidget {
  const _TourSummaryCard({required this.tour, required this.agencyLine});

  final TourDetail tour;
  final String agencyLine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TurIzimSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TurIzimStatusPill(
                label: tourStatusLabelTurkish(tour.status),
                tone: TurIzimStatusTone.success,
              ),
              TurIzimStatusPill(
                label: tourScopeLabelTurkish(tour.tourScope),
                tone: tour.tourScope == TourScope.international
                    ? TurIzimStatusTone.warning
                    : TurIzimStatusTone.info,
                icon: tour.tourScope == TourScope.international
                    ? Icons.public_rounded
                    : Icons.location_on_outlined,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            tour.title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: TurIzimPalette.deepNavy,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Acente: $agencyLine',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          _IconTextLine(
            icon: Icons.location_city_outlined,
            text: 'Çıkış şehri: ${tour.departureCity}',
          ),
          const SizedBox(height: 8),
          _IconTextLine(
            icon: Icons.route_rounded,
            text: 'Tur rotası: ${tourRouteOverviewLineTurkish(tour)}',
          ),
          const SizedBox(height: 8),
          _IconTextLine(
            icon: Icons.calendar_month_outlined,
            text:
                '${formatTourCalendarDate(tour.startsAt)} – ${formatTourCalendarDate(tour.endsAt)}',
          ),
          const SizedBox(height: 8),
          _IconTextLine(
            icon: Icons.event_seat_outlined,
            text:
                '${tour.seatsOffered} koltuk · Üretici kotası: ${tour.remainingCreatorSlots}/${tour.creatorQuota}',
          ),
          const SizedBox(height: 16),
          DecoratedBox(
            decoration: BoxDecoration(
              color: TurIzimPalette.softLavender.withValues(alpha: 0.52),
              borderRadius: BorderRadius.circular(
                TurIzimDesignTokens.radiusMedium,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _ValueRow(
                    label: 'Normal satış değeri',
                    value: formatTurkishLiraAmount(
                      tour.normalSalesPrice,
                      currencyCode: tour.currency,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _ValueRow(
                    label: 'Beklenen depozito',
                    value: formatTurkishLiraAmount(
                      tour.expectedDepositAmount,
                      currencyCode: tour.currency,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlockedStateBanner extends StatelessWidget {
  const _BlockedStateBanner({
    required this.duplicate,
    required this.eligible,
    required this.isInternational,
    required this.isOpenForApplications,
  });

  final bool duplicate;
  final bool eligible;
  final bool isInternational;
  final bool isOpenForApplications;

  @override
  Widget build(BuildContext context) {
    final message = _message();
    if (message == null) return const SizedBox.shrink();

    return TurIzimInfoBanner(
      title: 'Başvuru şu anda gönderilemez',
      message: message,
      tone: duplicate ? TurIzimStatusTone.warning : TurIzimStatusTone.danger,
      icon: Icons.info_outline_rounded,
    );
  }

  String? _message() {
    if (!eligible && !duplicate && isInternational) {
      return 'Bu yurt dışı turu için pasaport/vize uygunluğunuz bulunmuyor. Bu kontrol Aday Uygunluk Endeksi skoru değildir; ayrı başvuru kapısıdır.';
    }
    if (duplicate) {
      return 'Bu tur için zaten başvurunuz var; tekrar gönderilemez.';
    }
    if (!duplicate && !isOpenForApplications) {
      return 'Bu tur için başvuru kapalı.';
    }
    return null;
  }
}

class _CommitmentChecklistCard extends StatelessWidget {
  const _CommitmentChecklistCard({
    required this.blocked,
    required this.onChanged,
  });

  final bool blocked;
  final CommitmentChanged onChanged;

  @override
  Widget build(BuildContext context) {
    return TurIzimSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TurIzimSectionHeader(
            overline: 'Zorunlu kapı',
            title: 'Taahhüt onayları',
            subtitle:
                'Bu üç onay kutusu Aday Uygunluk Endeksi parçası değildir; başvuru oluşturma kapısıdır ve ön seçili gelemez.',
          ),
          const SizedBox(height: 12),
          IgnorePointer(
            ignoring: blocked,
            child: Opacity(
              opacity: blocked ? 0.5 : 1,
              child: MandatoryApplicationCheckboxes(onChanged: onChanged),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmitCard extends StatelessWidget {
  const _SubmitCard({
    required this.submitting,
    required this.blocked,
    required this.commitmentComplete,
    required this.onSubmit,
  });

  final bool submitting;
  final bool blocked;
  final bool commitmentComplete;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final enabled = !submitting && !blocked && commitmentComplete;

    return TurIzimSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TurIzimSectionHeader(
            overline: 'Son adım',
            title: 'Başvuruyu gönder',
            subtitle:
                'Başvurunuz acentenin manuel değerlendirme listesine eklenir; otomatik seçim yapılmaz.',
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: enabled ? onSubmit : null,
              child: submitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Başvuruyu Gönder'),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconTextLine extends StatelessWidget {
  const _IconTextLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 18, color: TurIzimPalette.royalIndigo),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.35,
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

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: TurIzimPalette.deepNavy,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
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
