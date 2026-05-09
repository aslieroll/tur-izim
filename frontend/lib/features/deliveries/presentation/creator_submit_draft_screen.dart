import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tur_izim/app/router.dart';
import 'package:tur_izim/app/tur_izim_scope.dart';
import 'package:tur_izim/core/di/tur_izim_dependencies.dart';
import 'package:tur_izim/core/errors/app_exception.dart';
import 'package:tur_izim/shared/theme/tur_izim_design_tokens.dart';
import 'package:tur_izim/shared/widgets/external_link_input.dart';
import 'package:tur_izim/shared/widgets/tur_izim_info_banner.dart';
import 'package:tur_izim/shared/widgets/tur_izim_primary_button.dart';
import 'package:tur_izim/shared/widgets/tur_izim_section_header.dart';
import 'package:tur_izim/shared/widgets/tur_izim_status_pill.dart';
import 'package:tur_izim/shared/widgets/tur_izim_surface_card.dart';

class CreatorSubmitDraftScreen extends StatefulWidget {
  const CreatorSubmitDraftScreen({required this.assignmentId, super.key});

  final String assignmentId;

  @override
  State<CreatorSubmitDraftScreen> createState() =>
      _CreatorSubmitDraftScreenState();
}

class _CreatorSubmitDraftScreenState extends State<CreatorSubmitDraftScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlCtrl = TextEditingController();

  bool _busy = false;

  static const List<String> _checklistBullets = <String>[
    'Bağlantı https:// ile başlamalı (http:// bazı MVP testlerinde kabul '
        'edilebilir; canlı yayında https önerilir).',
    'Bu ekrandan dosya seçme veya sürükleyip bırakma yoktur; bağlantının '
        'erişimi paylaşım platformundaki görünüm iznine bağlıdır.',
    'İçeriği doğrudan uygulamaya video veya dosya olarak yükleme gerekmiyor.',
    'Liste paylaşımı (Drive / iCloud / Dropbox vb.) oluşturan üreticinin hesabına '
        'bağlıdır; acente bağlantıyı açabilmelidir.',
  ];

  @override
  void dispose() {
    _urlCtrl.dispose();
    super.dispose();
  }

  String? _urlValidator(String? v) {
    final t = v?.trim() ?? '';
    if (t.length < 8) return 'Bağlantı gerekli.';
    if (!t.startsWith('http://') && !t.startsWith('https://')) {
      return 'Geçerli bir http/https bağlantısı gir.';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final url = _urlCtrl.text.trim();
    final deps = TurIzimDependencies.of(context);
    final session = TurIzimScope.of(context);

    setState(() => _busy = true);
    try {
      await deps.deliveries.submitDraftUrl(
        assignmentId: widget.assignmentId,
        creatorId: session.activeCreatorId!,
        url: url,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Taslak bağlantısı iletildi.')),
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
      backgroundColor: TurIzimPalette.warmWhite,
      appBar: AppBar(
        title: Text(
          'İçerik Teslimi',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: TurIzimPalette.deepNavy,
                fontWeight: FontWeight.w700,
              ),
        ),
        backgroundColor: TurIzimPalette.warmWhite,
        foregroundColor: TurIzimPalette.deepNavy,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final gutter = constraints.maxWidth > TurIzimDesignTokens.maxReadableWidth + 48
              ? (constraints.maxWidth - TurIzimDesignTokens.maxReadableWidth) / 2
              : TurIzimDesignTokens.pageMargin;
          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  gutter,
                  TurIzimDesignTokens.stackSmall,
                  gutter,
                  TurIzimDesignTokens.stackLarge,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      TurIzimInfoBanner(
                        tone: TurIzimStatusTone.info,
                        icon: Icons.cloud_outlined,
                        message:
                            'İçeriğini Google Drive, iCloud, Dropbox veya benzeri '
                            'harici bağlantı ile paylaş. Dosya seçme veya uygulama '
                            'içi yükleme yoktur.',
                      ),
                      const SizedBox(height: TurIzimDesignTokens.stackMedium),
                      TurIzimSurfaceCard(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const TurIzimSectionHeader(
                                title: 'Harici teslim bağlantısı',
                                subtitle:
                                    'Üniversite öğrencisi içerik üreticisi olarak '
                                    'doğrulanabilir ve paylaşıma uygun bir URL '
                                    'kullandığından emin ol.',
                              ),
                              const SizedBox(height: TurIzimDesignTokens.stackMedium),
                              ExternalLinkInput(
                                controller: _urlCtrl,
                                label: 'İçerik bağlantısı (URL)',
                                hint: 'https://…',
                                helperText:
                                    'Paylaşımı “Bağlantıyı olan herkes görüntüleyebilir” '
                                    'gibi uygun görünürlükte tut.',
                                validator: _urlValidator,
                              ),
                            ],
                          ),
                        ),
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
                                  icon: Icons.fact_check_outlined,
                                  label: 'Teknik kontrol listesi',
                                ),
                              ],
                            ),
                            const SizedBox(height: TurIzimDesignTokens.stackMedium),
                            ..._checklistBullets.map(
                              (line) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '•',
                                      style: Theme.of(context).textTheme.bodyMedium
                                          ?.copyWith(
                                        color: TurIzimPalette.royalIndigo,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        line,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: TurIzimPalette.slateText,
                                              height: 1.42,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: TurIzimDesignTokens.stackMedium),
                      TurIzimPrimaryButton(
                        label: _busy ? 'Gönderiliyor…' : 'İçerik Linkini Gönder',
                        icon: _busy ? null : Icons.link_rounded,
                        onPressed: _busy ? null : _submit,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
