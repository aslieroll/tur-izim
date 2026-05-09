import 'package:flutter/material.dart';

import 'package:tur_izim/core/constants/app_constants.dart';
import 'package:tur_izim/core/di/tur_izim_dependencies.dart';
import 'package:tur_izim/core/errors/app_exception.dart';
import 'package:tur_izim/shared/models/social_platform.dart';
import 'package:tur_izim/shared/models/violation_report.dart';
import 'package:tur_izim/shared/models/violation_report_status.dart';
import 'package:tur_izim/shared/presentation/status_label_turkish.dart';
import 'package:tur_izim/shared/theme/tur_izim_design_tokens.dart';
import 'package:tur_izim/shared/widgets/tur_izim_info_banner.dart';
import 'package:tur_izim/shared/widgets/tur_izim_primary_button.dart';
import 'package:tur_izim/shared/widgets/tur_izim_secondary_button.dart';
import 'package:tur_izim/shared/widgets/tur_izim_status_pill.dart';
import 'package:tur_izim/shared/widgets/tur_izim_surface_card.dart';

String _socialPlatformLabelTurkish(SocialPlatform p) => switch (p) {
      SocialPlatform.instagram => 'Instagram',
      SocialPlatform.tiktok => 'TikTok',
      SocialPlatform.youtube => 'YouTube',
      SocialPlatform.other => 'Diğer',
    };

/// Manuel ihlal incelemesi (mock repository). Otomatik ceza/tahsilat yoktur.
class AdminViolationReviewScreen extends StatefulWidget {
  const AdminViolationReviewScreen({required this.violation, super.key});

  final ViolationReport violation;

  @override
  State<AdminViolationReviewScreen> createState() =>
      _AdminViolationReviewScreenState();
}

class _AdminViolationReviewScreenState extends State<AdminViolationReviewScreen> {
  late final TextEditingController _note = TextEditingController();
  ViolationMissionContext? _context;
  bool _loadingCtx = false;
  String? _ctxError;
  bool _busyApprove = false;
  bool _busyReject = false;

  ViolationReport get _v => widget.violation;

  bool get _actionable =>
      _v.status == ViolationReportStatus.open ||
      _v.status == ViolationReportStatus.underReview;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadContext());
  }

  Future<void> _loadContext() async {
    final deps = TurIzimDependencies.of(context);
    setState(() {
      _loadingCtx = true;
      _ctxError = null;
    });

    final detail = await deps.assignments.loadAssignmentDetail(
      assignmentId: _v.assignmentId,
      viewerCreatorId: null,
      viewerAgencyId: null,
    );

    if (!mounted) return;
    if (detail == null) {
      setState(() {
        _loadingCtx = false;
        _ctxError = 'Görev kaydı görülemiyor; acente tarafından mı bildirildiğini doğrulayın.';
      });
      return;
    }

    final pubUrl = detail.publication?.publishedUrl;
    final platform = detail.publication?.platform;
    final agencyLabel =
        detail.tour.agencyLegalName ?? detail.summary.agencyLegalName;

    setState(() {
      _context = ViolationMissionContext(
        tourTitle: detail.tour.title,
        assignmentLabel: detail.summary.id,
        publicationUrl: pubUrl,
        platformLabel:
            platform == null ? null : _socialPlatformLabelTurkish(platform),
        agencyLegalName: agencyLabel,
      );
      _loadingCtx = false;
    });
  }

  Future<void> _resolve(bool confirmViolation) async {
    final trimmed = _note.text.trim();
    if (trimmed.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Manuel karar notu için en az 8 karakter girin.'),
        ),
      );
      return;
    }

    setState(() {
      if (confirmViolation) {
        _busyApprove = true;
      } else {
        _busyReject = true;
      }
    });

    final deps = TurIzimDependencies.of(context);
    try {
      await deps.violations.resolveByAdmin(
        violationId: _v.id,
        resolutionNote: trimmed,
        confirmViolation: confirmViolation,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            confirmViolation
                ? 'Karar kaydedildi: bildirimi uygun görüldü (mock).'
                : 'Karar kaydedildi: bildirimi reddettiniz (mock).',
          ),
        ),
      );
      Navigator.of(context).pop(true);
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _busyApprove = false;
          _busyReject = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: TurIzimPalette.warmWhite,
      appBar: AppBar(
        backgroundColor: TurIzimPalette.warmWhite,
        foregroundColor: TurIzimPalette.deepNavy,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'İhlal incelemesi',
          style: theme.textTheme.titleMedium?.copyWith(
            color: TurIzimPalette.deepNavy,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.pageHorizontalMargin,
          20,
          AppConstants.pageHorizontalMargin,
          32,
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TurIzimStatusPill(
              tone: TurIzimStatusTone.warning,
              icon: Icons.gavel_rounded,
              label: violationReportStatusLabelTurkish(_v.status),
            ),
          ),
          const SizedBox(height: 14),
          TurIzimSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'İhlal özeti',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: TurIzimPalette.deepNavy,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _v.reason.trim(),
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          TurIzimSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kanıt bağlantısı',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: TurIzimPalette.deepNavy,
                  ),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  (_v.evidenceUrl == null || _v.evidenceUrl!.trim().isEmpty)
                      ? '— Ek URL belirtilmedi.'
                      : _v.evidenceUrl!.trim(),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (_loadingCtx)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator.adaptive(),
              ),
            ),
          if (_ctxError != null)
            TurIzimInfoBanner(
              tone: TurIzimStatusTone.warning,
              icon: Icons.warning_amber_rounded,
              title: 'Özet yükleme uyarısı',
              message: _ctxError!,
            ),
          if (_context != null) ...[
            TurIzimSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Yayın / görev bilgisi',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: TurIzimPalette.deepNavy,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_context!.tourTitle != null)
                    _Line(
                      icon: Icons.tour_rounded,
                      label: 'İlan',
                      text: _context!.tourTitle!,
                    ),
                  if (_context!.agencyLegalName != null) ...[
                    const SizedBox(height: 10),
                    _Line(
                      icon: Icons.business_outlined,
                      label: 'Acente kaydı',
                      text: _context!.agencyLegalName!,
                    ),
                  ],
                  const SizedBox(height: 10),
                  _Line(
                    icon: Icons.assignment_turned_in_outlined,
                    label: 'Görev kimliği',
                    text: _context!.assignmentLabel,
                  ),
                  if (_context!.platformLabel != null) ...[
                    const SizedBox(height: 10),
                    _Line(
                      icon: Icons.public_rounded,
                      label: 'Yayıncılık taşıyıcısı',
                      text: _context!.platformLabel!,
                    ),
                  ],
                  const SizedBox(height: 14),
                  Text(
                    'Yayın URL',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: TurIzimPalette.deepNavy,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SelectableText(
                    (_context!.publicationUrl == null ||
                            _context!.publicationUrl!.trim().isEmpty)
                        ? '— Henüz URL yok.'
                        : _context!.publicationUrl!.trim(),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          const TurIzimInfoBanner(
            tone: TurIzimStatusTone.info,
            icon: Icons.record_voice_over_outlined,
            title: 'Manuel inceleme',
            message:
                'Kararların tamamı bu panelde yazılı olarak tutulur (mock). '
                    'Platform otomatik ceza kesmez ve gerçek para hareketini '
                    'başlatmaz.',
          ),
          const SizedBox(height: TurIzimDesignTokens.stackMedium),
          TextField(
            controller: _note,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Manuel inceleme notu',
              hintText:
                  'Gerekçeli ve ölçülü yazın (örn. tarih doğrulanamadı, görünürlük kapsamı…)',
              floatingLabelBehavior: FloatingLabelBehavior.always,
              border: OutlineInputBorder(),
            ),
            enabled: _actionable,
          ),
          if (!_actionable)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: TurIzimInfoBanner(
                tone: TurIzimStatusTone.neutral,
                icon: Icons.checklist_rtl_rounded,
                title: 'İşlem yapılmaz',
                message:
                    'Bu kayıt önceki karar nedeniyle kapatılmış. Yeni karar için '
                        'yeniden bildirim açılması gerekir (MVP politikası · mock).',
              ),
            ),
          if (_actionable) ...[
            const SizedBox(height: 24),
            TurIzimPrimaryButton(
              label: 'Onayla',
              icon: Icons.check_circle_outline_rounded,
              onPressed: (_busyApprove || _busyReject)
                  ? null
                  : () => _resolve(true),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: (_busyApprove || _busyReject)
                  ? null
                  : () => _resolve(false),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(
                  color: theme.colorScheme.error.withValues(alpha: 0.45),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  'Reddet',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: TurIzimDesignTokens.stackMedium),
          TurIzimSecondaryButton(
            label: 'Kapat',
            icon: Icons.close_rounded,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class ViolationMissionContext {
  const ViolationMissionContext({
    required this.tourTitle,
    required this.assignmentLabel,
    required this.publicationUrl,
    required this.platformLabel,
    required this.agencyLegalName,
  });

  final String? tourTitle;
  final String assignmentLabel;
  final String? publicationUrl;
  final String? platformLabel;
  final String? agencyLegalName;
}

class _Line extends StatelessWidget {
  const _Line({
    required this.icon,
    required this.label,
    required this.text,
  });

  final IconData icon;
  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: TurIzimPalette.royalIndigo),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: TurIzimPalette.deepNavy,
                    ),
              ),
              const SizedBox(height: 2),
              SelectableText(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface,
                      height: 1.42,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
