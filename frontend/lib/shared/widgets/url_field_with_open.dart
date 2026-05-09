import 'package:flutter/material.dart';

import 'package:tur_izim/shared/widgets/external_link_input.dart';

/// URL girişi + panoya kopyalama (harici paket gerektirmeden paylaşım).
class UrlFieldWithOpen extends StatelessWidget {
  const UrlFieldWithOpen({
    super.key,
    required this.controller,
    this.label = 'Bağlantı (URL)',
    this.hint = 'https://...',
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return ExternalLinkInput(
      controller: controller,
      label: label,
      hint: hint,
      helperText: 'Google Drive, iCloud, Dropbox veya yayın URL bağlantısı.',
      validator: validator,
    );
  }
}
