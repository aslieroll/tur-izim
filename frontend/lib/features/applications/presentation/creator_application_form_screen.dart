import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tur_izim/app/router.dart';
import 'package:tur_izim/app/tur_izim_scope.dart';
import 'package:tur_izim/core/di/tur_izim_dependencies.dart';
import 'package:tur_izim/core/errors/app_exception.dart';
import 'package:tur_izim/shared/models/application_commitment.dart';
import 'package:tur_izim/shared/models/tour_detail.dart';
import 'package:tur_izim/shared/models/tour_scope.dart';
import 'package:tur_izim/shared/presentation/status_label_turkish.dart';
import 'package:tur_izim/shared/presentation/tour_display_format.dart';
import 'package:tur_izim/shared/widgets/international_mandatory_requirements_card.dart';
import 'package:tur_izim/shared/widgets/mandatory_application_checkboxes.dart';
import 'package:tur_izim/shared/widgets/publication_commitment_info_card.dart';
import 'package:tur_izim/shared/widgets/status_badge.dart';
import 'package:tur_izim/shared/widgets/tour_pricing_info_lines.dart';

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
        const SnackBar(content: Text('Başvuru mock olarak kaydedildi.')),
      );
      context.go(AppRoutes.creatorApplications);
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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

          final agencyLine = tour.agencyLegalName ?? 'Acente bilgisi yok';
          final blocked = duplicate || !tour.isOpenForApplications || !eligible;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card.outlined(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tour.title, style: theme.textTheme.titleMedium),
                        const SizedBox(height: 6),
                        Text('Acente: $agencyLine'),
                        const SizedBox(height: 4),
                        Text(
                          '${tour.departureCity} → '
                          '${destinationClusterLabelTurkish(tour.destinationCluster)}',
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${formatTourCalendarDate(tour.startsAt)} – '
                          '${formatTourCalendarDate(tour.endsAt)}',
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${tour.seatsOffered} koltuk · '
                          'Üretici kotası: ${tour.remainingCreatorSlots}/'
                          '${tour.creatorQuota}',
                        ),
                        const SizedBox(height: 8),
                        TourPricingInfoLines(tour: tour),
                        const SizedBox(height: 8),
                        InternationalMandatoryRequirementsCard(tour: tour),
                        const SizedBox(height: 8),
                        StatusBadge(label: tourStatusLabelTurkish(tour.status)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (!eligible &&
                    !duplicate &&
                    tour.tourScope == TourScope.international)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Bu yurt dışı turu için pasaport/vize uygunluğunuz '
                      'bulunmuyor.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                if (duplicate)
                  Text(
                    'Bu tur için zaten başvurunuz var; tekrar gönderilemez.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                if (!duplicate && !tour.isOpenForApplications)
                  Text(
                    'Bu tur için başvuru kapalı.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                const SizedBox(height: 8),
                const PublicationCommitmentInfoCard(),
                const SizedBox(height: 16),
                Text('Zorunlu taahhütler', style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                IgnorePointer(
                  ignoring: blocked,
                  child: Opacity(
                    opacity: blocked ? 0.5 : 1,
                    child: MandatoryApplicationCheckboxes(
                      onChanged: (value) => setState(() => _commitment = value),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _messageCtrl,
                  enabled: !blocked,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Mesajınız (opsiyonel)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        (_submitting || blocked || !_commitment.isComplete)
                        ? null
                        : _submit,
                    child: _submitting
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Başvuruyu gönder (mock)'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
