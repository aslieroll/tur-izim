import 'package:flutter/material.dart';

import 'package:tur_izim/app/tur_izim_scope.dart';
import 'package:tur_izim/core/di/tur_izim_dependencies.dart';
import 'package:tur_izim/core/errors/app_exception.dart';
import 'package:tur_izim/shared/theme/tur_izim_design_tokens.dart';
import 'package:tur_izim/shared/widgets/external_link_input.dart';
import 'package:tur_izim/shared/widgets/tur_izim_info_banner.dart';
import 'package:tur_izim/shared/widgets/tur_izim_surface_card.dart';
import 'package:tur_izim/shared/widgets/tur_izim_status_pill.dart';

/// Acente ihlali manuel bildirir; otomatik ceza ve tahsilat yoktur (MVP).
class AgencyReportViolationScreen extends StatefulWidget {
  const AgencyReportViolationScreen({
    required this.assignmentId,
    required this.publicationId,
    super.key,
  });

  final String assignmentId;
  final String publicationId;

  @override
  State<AgencyReportViolationScreen> createState() =>
      _AgencyReportViolationScreenState();
}

class _AgencyReportViolationScreenState extends State<AgencyReportViolationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonCtrl = TextEditingController();
  final _evidenceCtrl = TextEditingController();

  bool _busy = false;

  @override
  void dispose() {
    _reasonCtrl.dispose();
    _evidenceCtrl.dispose();
    super.dispose();
  }

  String? _optionalUrlValidator(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return null;
    if (!(t.startsWith('http://') || t.startsWith('https://'))) {
      return 'http veya https ile başlamalıdır.';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final reason = _reasonCtrl.text.trim();

    final deps = TurIzimDependencies.of(context);
    final session = TurIzimScope.of(context);
    final ev = _evidenceCtrl.text.trim();

    setState(() => _busy = true);
    try {
      await deps.violations.createViolationReport(
        assignmentId: widget.assignmentId,
        publicationId: widget.publicationId,
        reporterAgencyId: session.activeAgencyId!,
        reason: reason,
        evidenceUrl: ev.isEmpty ? null : ev,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'İhlal bildirimin iletildi; değerlendirme manuel olarak yapılır (mock).',
          ),
        ),
      );
      Navigator.of(context).pop(true);
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
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: TurIzimPalette.warmWhite,
      appBar: AppBar(
        backgroundColor: TurIzimPalette.warmWhite,
        foregroundColor: TurIzimPalette.deepNavy,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'İhlal Bildirimi',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: TurIzimPalette.deepNavy,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final inset = constraints.maxWidth >
                  TurIzimDesignTokens.maxReadableWidth + 48
              ? (constraints.maxWidth - TurIzimDesignTokens.maxReadableWidth) / 2
              : TurIzimDesignTokens.pageMargin;
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              inset,
              TurIzimDesignTokens.stackSmall,
              inset,
              TurIzimDesignTokens.stackLarge + 32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TurIzimInfoBanner(
                  tone: TurIzimStatusTone.danger,
                  icon: Icons.info_outline_rounded,
                  title: 'Önemli',
                  message:
                      'Gerçek para için otomatik tahsil yoktur; bildirilen durum iş '
                              'sırasına alınır ve yöneticiler manuel olarak inceler. '
                              'Otomatik ceza ve geri tahsilat dili bu ekranın kapsamı '
                              'dışında kalmalıdır.',
                ),
                const SizedBox(height: TurIzimDesignTokens.stackMedium),
                TurIzimSurfaceCard(
                  padding: EdgeInsets.zero,
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding:
                          const EdgeInsets.all(TurIzimDesignTokens.cardPaddingLarge),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _reasonCtrl,
                            minLines: 4,
                            maxLines: 8,
                            validator: (v) {
                              final t = v?.trim() ?? '';
                              if (t.length < 8) {
                                return 'Gerekçeyi daha açık yazın.';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText:
                                  'Nesnel durum bildirimi (örnek: public erişimin erken düşmesi)',
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  TurIzimDesignTokens.radiusMedium,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: TurIzimDesignTokens.stackMedium),
                          ExternalLinkInput(
                            controller: _evidenceCtrl,
                            label: 'Kanıt URL (isteğe bağlı)',
                            hint: 'https://…',
                            helperText:
                                'Dosya yükleme yoktur; ekran görüntüsü veya zaman damgalı bağlantılar.',
                            validator: _optionalUrlValidator,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: TurIzimDesignTokens.stackMedium),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: scheme.error,
                      foregroundColor: scheme.onError,
                      elevation: 0,
                      shape: const StadiumBorder(),
                      minimumSize:
                          const Size(double.infinity, TurIzimDesignTokens.minTouchTarget),
                    ),
                    onPressed: _busy ? null : _submit,
                    child: _busy
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'İhlal Bildir',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                  ),
                ),
                const SizedBox(height: TurIzimDesignTokens.stackSmall),
                OutlinedButton(
                  onPressed: _busy ? null : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: TurIzimPalette.deepNavy,
                    side:
                        BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.7)),
                    shape: const StadiumBorder(),
                    minimumSize: const Size(
                      double.infinity,
                      TurIzimDesignTokens.minTouchTarget,
                    ),
                  ),
                  child: const Text('Vazgeç'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
