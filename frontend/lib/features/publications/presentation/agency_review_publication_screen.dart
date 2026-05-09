import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tur_izim/app/tur_izim_scope.dart';
import 'package:tur_izim/core/di/tur_izim_dependencies.dart';
import 'package:tur_izim/core/errors/app_exception.dart';
import 'package:tur_izim/features/violations/presentation/agency_report_violation_screen.dart';
import 'package:tur_izim/shared/models/assignment_detail.dart';
import 'package:tur_izim/shared/models/assignment_status.dart';
import 'package:tur_izim/shared/models/publication_record.dart';
import 'package:tur_izim/shared/models/publication_status.dart';
import 'package:tur_izim/shared/presentation/status_label_turkish.dart';
import 'package:tur_izim/shared/theme/tur_izim_design_tokens.dart';
import 'package:tur_izim/shared/widgets/tur_izim_info_banner.dart';
import 'package:tur_izim/shared/widgets/tur_izim_primary_button.dart';
import 'package:tur_izim/shared/widgets/tur_izim_secondary_button.dart';
import 'package:tur_izim/shared/widgets/tur_izim_surface_card.dart';
import 'package:tur_izim/shared/widgets/tur_izim_status_pill.dart';

/// Acente yayın bağlantısını doğrular; otomatik sosyal medya crawler yoktur (MVP).
class AgencyReviewPublicationScreen extends StatefulWidget {
  const AgencyReviewPublicationScreen({required this.assignmentId, super.key});

  final String assignmentId;

  @override
  State<AgencyReviewPublicationScreen> createState() =>
      _AgencyReviewPublicationScreenState();
}

class _AgencyReviewPublicationScreenState
    extends State<AgencyReviewPublicationScreen> {
  AssignmentDetail? _detail;
  PublicationRecord? _publication;

  bool _loading = true;
  String? _error;
  bool _busyVerify = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final deps = TurIzimDependencies.of(context);
    final session = TurIzimScope.of(context);
    try {
      final detail = await deps.assignments.loadAssignmentDetail(
        assignmentId: widget.assignmentId,
        viewerCreatorId: null,
        viewerAgencyId: session.activeAgencyId!,
      );
      if (detail == null) throw AppException('Atama görülemiyor.');
      final publication = await deps.publications.fetchForAssignment(
        widget.assignmentId,
      );
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _publication = publication;
        _loading = false;
      });
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Yükleme hatası.';
        _loading = false;
      });
    }
  }

  Future<void> _copyUrl(String? url) async {
    if (url == null || url.trim().isEmpty) return;
    await Clipboard.setData(ClipboardData(text: url.trim()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bağlantı panoya kopyalandı.')),
    );
  }

  Future<void> _verify() async {
    final deps = TurIzimDependencies.of(context);
    final session = TurIzimScope.of(context);
    setState(() => _busyVerify = true);
    try {
      await deps.publications.agencyVerifyPublication(
        assignmentId: widget.assignmentId,
        actingAgencyId: session.activeAgencyId!,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yayın bağlantısı onaylandı (mock).')),
      );
      if (mounted) Navigator.of(context).pop(true);
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busyVerify = false);
    }
  }

  bool get _canVerify =>
      _detail != null &&
      _detail!.summary.status == AssignmentStatus.publicationSubmitted &&
      (_publication?.publishedUrl ?? '').trim().isNotEmpty;

  bool get _canShowViolationActions =>
      _publication != null &&
      ((_detail?.summary.status == AssignmentStatus.publicationSubmitted ||
              _detail?.summary.status == AssignmentStatus.under30DayMonitoring) &&
          (_publication!.publishedUrl ?? '').trim().isNotEmpty);

  Future<void> _openViolationSheet() async {
    final publication = _publication;
    if (publication == null) return;
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => AgencyReportViolationScreen(
          assignmentId: widget.assignmentId,
          publicationId: publication.id,
        ),
      ),
    );
    if (!mounted || changed != true) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final contentReady = !_loading && _error == null && _detail != null;

    return Scaffold(
      backgroundColor: TurIzimPalette.warmWhite,
      appBar: AppBar(
        backgroundColor: TurIzimPalette.warmWhite,
        foregroundColor: TurIzimPalette.deepNavy,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Yayın İncelemesi',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: TurIzimPalette.deepNavy,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
      bottomNavigationBar: contentReady
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  TurIzimDesignTokens.pageMargin,
                  12,
                  TurIzimDesignTokens.pageMargin,
                  16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!_canVerify && _detail!.summary.status == AssignmentStatus.publicationSubmitted)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          'Üreticiden yayın bağı bildirilene kadar bağlantı onayı mümkün değil.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color:
                                    Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                    TurIzimPrimaryButton(
                      label:
                          _busyVerify ? 'Onaylıyorum…' : 'Yayını Onayla',
                      icon: Icons.verified_rounded,
                      onPressed: _busyVerify ? null : (_canVerify ? _verify : null),
                    ),
                    if (_canShowViolationActions && !_busyVerify) ...[
                      const SizedBox(height: TurIzimDesignTokens.stackSmall),
                      TurIzimSecondaryButton(
                        label: 'İhlal Bildir',
                        icon: Icons.flag_outlined,
                        onPressed: () async => _openViolationSheet(),
                      ),
                    ],
                  ],
                ),
              ),
            )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.error,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        TurIzimSecondaryButton(
                          label: 'Yeniden dene',
                          onPressed: () => _bootstrap(),
                        ),
                      ],
                    ),
                  ),
                )
              : _buildMain(context),
    );
  }

  Widget _buildMain(BuildContext context) {
    final d = _detail!;
    final pub = _publication;
    final url = pub?.publishedUrl?.trim();

    return LayoutBuilder(
      builder: (context, constraints) {
        final inset = constraints.maxWidth >
                TurIzimDesignTokens.maxReadableWidth + 48
            ? (constraints.maxWidth - TurIzimDesignTokens.maxReadableWidth) / 2
            : TurIzimDesignTokens.pageMargin;
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                inset,
                TurIzimDesignTokens.stackSmall,
                inset,
                TurIzimDesignTokens.stackLarge,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    TurIzimInfoBanner(
                      tone: TurIzimStatusTone.warning,
                      icon: Icons.public_rounded,
                      title: '30 gün kamuya görünür olma şartı',
                      message:
                          'Onaysız otomatik sosyal medya crawler’ı çalışmaz. '
                              'Üniversite öğrencisi içerik üreticisinin bildirdiği '
                              'paylaşımın en az 30 gün herkese açık kalması '
                              'taahüdünün parçasıdır; erken silme bildirimi ayrı '
                              'bir operasyon sürecidir.',
                    ),
                    const SizedBox(height: TurIzimDesignTokens.stackMedium),
                    TurIzimSurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              TurIzimStatusPill(
                                tone: TurIzimStatusTone.info,
                                label: publicationStatusLabelTurkish(
                                  pub?.status ??
                                      PublicationStatus.waitingPublication,
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            d.tour.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: TurIzimPalette.deepNavy,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Atama: ${assignmentStatusLabelTurkish(d.summary.status)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: TurIzimDesignTokens.stackMedium),
                    TurIzimSurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Yayın URL',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: TurIzimPalette.deepNavy,
                                ),
                          ),
                          const SizedBox(height: 12),
                          if (url != null && url.isNotEmpty) ...[
                            SelectableText(
                              url,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            TurIzimSecondaryButton(
                              label: 'Bağlantıyı panoya kopyala',
                              icon: Icons.copy_rounded,
                              onPressed: () => _copyUrl(url),
                            ),
                          ] else ...[
                            Text(
                              'Yayın bağlantısı henüz bildirilmedi.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (pub?.monitoringStartDate != null &&
                        pub?.monitoringEndDate != null)
                      Padding(
                        padding:
                            const EdgeInsets.only(top: TurIzimDesignTokens.stackMedium),
                        child: TurIzimSurfaceCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'İzlemeye alınmış dönem (mock tarihler)',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: TurIzimPalette.deepNavy,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Başlangıç: ${pub!.monitoringStartDate}\n'
                                'Bitiş: ${pub.monitoringEndDate}',
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'MVP’de otomatik doğrulama yoktur; bildirilmiş '
                                      'kuralları manuel izlersin.',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
