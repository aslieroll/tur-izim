import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:tur_izim/app/tur_izim_scope.dart';
import 'package:tur_izim/core/di/tur_izim_dependencies.dart';
import 'package:tur_izim/core/errors/app_exception.dart';
import 'package:tur_izim/shared/models/assignment_detail.dart';
import 'package:tur_izim/shared/models/assignment_status.dart';
import 'package:tur_izim/shared/models/tour_detail.dart';
import 'package:tur_izim/shared/presentation/status_label_turkish.dart';
import 'package:tur_izim/shared/presentation/tour_requirement_labels_turkish.dart';
import 'package:tur_izim/shared/theme/tur_izim_design_tokens.dart';
import 'package:tur_izim/shared/widgets/tur_izim_primary_button.dart';
import 'package:tur_izim/shared/widgets/tur_izim_secondary_button.dart';
import 'package:tur_izim/shared/widgets/tur_izim_info_banner.dart';
import 'package:tur_izim/shared/widgets/tur_izim_surface_card.dart';
import 'package:tur_izim/shared/widgets/tur_izim_status_pill.dart';

/// Acente — harici içerik bağlantısını işler (yükleme yoktur).
class AgencyReviewContentDeliveryScreen extends StatefulWidget {
  const AgencyReviewContentDeliveryScreen({
    required this.assignmentId,
    super.key,
  });

  final String assignmentId;

  @override
  State<AgencyReviewContentDeliveryScreen> createState() =>
      _AgencyReviewContentDeliveryScreenState();
}

class _AgencyReviewContentDeliveryScreenState
    extends State<AgencyReviewContentDeliveryScreen> {
  AssignmentDetail? _detail;
  TourDetail? _tourDetail;
  bool _loading = true;
  String? _error;
  bool _busyApprove = false;
  bool _busyRevision = false;

  static const List<String> _processBullets = <String>[
    'Dosya seçme veya uygulama içi yükleme yoktur; yalnızca bağlantı incelemesi.',
    'Revizyon talebi nesnel teknik gerekçe ile sınırlı olmalıdır (çözünürlük, süre vb.).',
    'Subjektif ifadeler (örn. görsel olarak beğenilmedi) bu akış için önerilmez.',
  ];

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
      final tourDetail = await deps.tours.fetchTourDetail(detail.tour.id);
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _tourDetail = tourDetail;
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

  Future<void> _reload() async {
    setState(() {
      _detail = null;
      _tourDetail = null;
    });
    await _bootstrap();
  }

  Future<void> _copyUrl(String? url) async {
    if (url == null || url.trim().isEmpty) return;
    await Clipboard.setData(ClipboardData(text: url.trim()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bağlantı panoya kopyalandı.')),
    );
  }

  Future<void> _approve() async {
    final deps = TurIzimDependencies.of(context);
    final session = TurIzimScope.of(context);
    setState(() => _busyApprove = true);
    try {
      await deps.deliveries.approveDraft(
        assignmentId: widget.assignmentId,
        actingAgencyId: session.activeAgencyId!,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İçerik bağlantısı onaylandı (mock).')),
      );
      Navigator.of(context).pop(true);
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busyApprove = false);
    }
  }

  Future<void> _requestRevision() async {
    final notes = await _showTechnicalRevisionSheet(context);
    if (notes == null) return;
    if (!mounted) return;

    final deps = TurIzimDependencies.of(context);
    final session = TurIzimScope.of(context);
    setState(() => _busyRevision = true);
    try {
      await deps.deliveries.requestTechnicalRevision(
        assignmentId: widget.assignmentId,
        actingAgencyId: session.activeAgencyId!,
        checklistNotes: notes,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Teknik revizyon talebi kaydedildi (mock).')),
      );
      Navigator.of(context).pop(true);
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busyRevision = false);
    }
  }

  Future<String?> _showTechnicalRevisionSheet(BuildContext context) async {
    final ctrl = TextEditingController();

    try {
      final result = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        builder: (ctx) {
          final bottomInset = MediaQuery.paddingOf(ctx).bottom;
          return Padding(
            padding: EdgeInsets.fromLTRB(
              TurIzimDesignTokens.pageMargin,
              16,
              TurIzimDesignTokens.pageMargin,
              MediaQuery.of(ctx).viewInsets.bottom + 16 + bottomInset,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Teknik revizyon talebi',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: TurIzimPalette.deepNavy,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Madde işaretleriyle gereksinimlere uygun nesnel eksikleri '
                    'yazın; estetik tercihi değerlendirmesi değildir.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: TurIzimPalette.mutedText,
                          height: 1.42,
                        ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: ctrl,
                    minLines: 4,
                    maxLines: 8,
                    decoration: InputDecoration(
                      hintText:
                          'Teknik gereksinim bağlantılı gerekçe (örnek: doğru süre etiketi, format, çözünürlük…)…',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          TurIzimDesignTokens.radiusMedium,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TurIzimPrimaryButton(
                    label: 'Revizyonu gönder',
                    onPressed: () {
                      final t = ctrl.text.trim();
                      if (t.length < 6) return;
                      Navigator.of(ctx).pop(t);
                    },
                  ),
                  const SizedBox(height: 8),
                  TurIzimSecondaryButton(
                    label: 'Vazgeç',
                    onPressed: () => Navigator.of(ctx).pop<String?>(),
                  ),
                ],
              ),
            ),
          );
        },
      );

      final out = result?.trim();
      if (out == null || out.isEmpty) return null;
      return out;
    } finally {
      ctrl.dispose();
    }
  }

  bool get _canAct =>
      _detail != null &&
      _detail!.summary.status == AssignmentStatus.waitingAgencyApproval;

  @override
  Widget build(BuildContext context) {
    final actionsReady = !_loading && _error == null && _detail != null;
    final canPress = actionsReady &&
        _canAct &&
        !_busyApprove &&
        !_busyRevision;

    return Scaffold(
      backgroundColor: TurIzimPalette.warmWhite,
      appBar: AppBar(
        backgroundColor: TurIzimPalette.warmWhite,
        foregroundColor: TurIzimPalette.deepNavy,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'İçerik İncelemesi',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: TurIzimPalette.deepNavy,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
      bottomNavigationBar: actionsReady
          ? SafeArea(
              minimum: EdgeInsets.zero,
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
                    if (!_canAct)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Bu aşamada bağlantı incelemesi beklenmiyor veya kota '
                              'tamamlanıncaya kadar bekle.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color:
                                    Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    TurIzimPrimaryButton(
                      label:
                          _busyApprove ? 'Onay kaydediliyor…' : 'İçeriği Onayla',
                      icon: Icons.verified_rounded,
                      onPressed: canPress ? _approve : null,
                    ),
                    const SizedBox(height: TurIzimDesignTokens.stackSmall),
                    TurIzimSecondaryButton(
                      label: _busyRevision
                          ? 'Gönderiliyor…'
                          : 'Revizyon İste',
                      icon: Icons.build_circle_outlined,
                      onPressed:
                          canPress && !_busyApprove && !_busyRevision
                              ? _requestRevision
                              : null,
                    ),
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
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        TurIzimSecondaryButton(
                          label: 'Yeniden dene',
                          onPressed: _reload,
                        ),
                      ],
                    ),
                  ),
                )
              : _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final d = _detail!;
    final delivery = d.delivery;
    final url = delivery?.draftContentUrl?.trim();

    return LayoutBuilder(
      builder: (context, constraints) {
        final inset = constraints.maxWidth >
                TurIzimDesignTokens.maxReadableWidth + 48
            ? (constraints.maxWidth - TurIzimDesignTokens.maxReadableWidth) / 2
            : TurIzimDesignTokens.pageMargin;
        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                      icon: Icons.link_rounded,
                      title: 'Harici teslim bağlantısı',
                      message:
                          'Üniversite öğrencisi içerik üreticisi dosya yüklemez; '
                          'yalnızca bulut bağlantısı paylaşılır.',
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
                                label: assignmentStatusLabelTurkish(d.summary.status),
                                icon: Icons.assignment_turned_in_outlined,
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
                          const SizedBox(height: 6),
                          Text(
                            delivery == null || url == null || url.isEmpty
                                ? 'Bu aşama için teslim bağlantısı bekleniyor.'
                                : 'Bağlantı aşağıda; panoya kopyalayarak harici olarak aç.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  height: 1.4,
                                  color:
                                      Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          if (url != null && url.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            SelectableText(
                              url,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            TurIzimSecondaryButton(
                              label: 'Bağlantıyı panoya kopyala',
                              icon: Icons.copy_rounded,
                              onPressed: () => _copyUrl(url),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: TurIzimDesignTokens.stackMedium),
                    TurIzimSurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'İlan teknik gereksinim checklist’i',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: TurIzimPalette.deepNavy,
                                ),
                          ),
                          const SizedBox(height: 10),
                          if (_tourDetail == null || _tourDetail!.requirements.isEmpty)
                            Text(
                              _tourDetail == null
                                  ? 'Gereksinim listesi yüklenemedi.'
                                  : 'Bu ilanda ek teknik kriter bildirimi yok.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            )
                          else
                            ..._tourDetail!.requirements.map((r) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline_rounded,
                                      color: TurIzimPalette.royalIndigo,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        tourRequirementShortLabelTurkish(r),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(height: 1.38),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                    const SizedBox(height: TurIzimDesignTokens.stackMedium),
                    TurIzimSurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TurIzimStatusPill(
                            tone: TurIzimStatusTone.info,
                            icon: Icons.fact_check_rounded,
                            label: 'İnceleme akışı',
                          ),
                          const SizedBox(height: 12),
                          ..._processBullets.map(
                            (b) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.arrow_right_alt_rounded,
                                    size: 18,
                                    color: TurIzimPalette.softCoral,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(b)),
                                ],
                              ),
                            ),
                          ),
                        ],
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

