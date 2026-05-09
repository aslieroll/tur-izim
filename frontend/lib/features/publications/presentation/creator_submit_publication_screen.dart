import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tur_izim/app/router.dart';
import 'package:tur_izim/app/tur_izim_scope.dart';
import 'package:tur_izim/core/di/tur_izim_dependencies.dart';
import 'package:tur_izim/core/errors/app_exception.dart';
import 'package:tur_izim/shared/theme/tur_izim_design_tokens.dart';
import 'package:tur_izim/shared/widgets/external_link_input.dart';
import 'package:tur_izim/shared/widgets/publication_commitment_info_card.dart';
import 'package:tur_izim/shared/widgets/tur_izim_info_banner.dart';
import 'package:tur_izim/shared/widgets/tur_izim_primary_button.dart';
import 'package:tur_izim/shared/widgets/tur_izim_section_header.dart';
import 'package:tur_izim/shared/widgets/tur_izim_status_pill.dart';
import 'package:tur_izim/shared/widgets/tur_izim_surface_card.dart';

class CreatorSubmitPublicationScreen extends StatefulWidget {
  const CreatorSubmitPublicationScreen({required this.assignmentId, super.key});

  final String assignmentId;

  @override
  State<CreatorSubmitPublicationScreen> createState() =>
      _CreatorSubmitPublicationScreenState();
}

class _CreatorSubmitPublicationScreenState
    extends State<CreatorSubmitPublicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ctrl = TextEditingController();

  bool _busy = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String? _urlValidator(String? v) {
    final t = v?.trim() ?? '';
    if (t.length < 8) return 'Bağlantı gerekli.';
    if (!t.startsWith('http://') && !t.startsWith('https://')) {
      return 'Geçerli bir yayın bağlantısı gir (http/https ile başlamalı).';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final url = _ctrl.text.trim();
    final deps = TurIzimDependencies.of(context);
    final session = TurIzimScope.of(context);

    setState(() => _busy = true);
    try {
      await deps.publications.submitPublicationUrl(
        assignmentId: widget.assignmentId,
        creatorId: session.activeCreatorId!,
        publishedUrl: url,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yayın bağlantısı iletildi (mock).')),
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
          'Yayın Bildirimi',
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
                        tone: TurIzimStatusTone.warning,
                        icon: Icons.calendar_month_rounded,
                        title: '30 gün herkese açık yayın şartı',
                        message:
                            'Bildirdiğin yayın bağlantısı en az 30 gün süreyle '
                            'kamuya görünür kalmalıdır. Süresinden önce '
                            'gizleme veya silmede başvurduğun taahüt ve acente süreci '
                            'kapsamında bildirim açılabilir; otomatik idare yoktur. '
                            'Bu ekrandan video veya dosya yükleme yoktur; yalnızca '
                            'harici bağlantı paylaşılır. MVP\'de bağlantılar için '
                            'otomatik doğrulama veya crawler yoktur.',
                      ),
                      const SizedBox(height: TurIzimDesignTokens.stackMedium),
                      const PublicationCommitmentInfoCard(),
                      const SizedBox(height: TurIzimDesignTokens.stackMedium),
                      TurIzimSurfaceCard(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const TurIzimSectionHeader(
                                title: 'Yayında olan gönderiye bağlantı',
                                subtitle:
                                    'Instagram, TikTok, YouTube veya blog gibi yayın '
                                    'konumundan doğrudan paylaşım URL’sini yapıştır.',
                              ),
                              const SizedBox(height: TurIzimDesignTokens.stackMedium),
                              ExternalLinkInput(
                                controller: _ctrl,
                                label: 'Yayın bağlantısı (URL)',
                                hint: 'https://…',
                                helperText:
                                    'Yalnızca harici bağlantı; doğrulama acente sürecinin '
                                    'parçasıdır.',
                                validator: _urlValidator,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: TurIzimDesignTokens.stackMedium),
                      TurIzimPrimaryButton(
                        label: _busy ? 'Gönderiliyor…' : 'Yayını Bildir',
                        icon: _busy ? null : Icons.campaign_rounded,
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
