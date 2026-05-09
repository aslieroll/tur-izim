import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Harici URL girişi.
///
/// İçerik teslimi/yayın bildirimi URL ile yapılır; bu bileşen dosya veya video
/// yükleme davranışı eklemez.
class ExternalLinkInput extends StatefulWidget {
  const ExternalLinkInput({
    required this.controller,
    super.key,
    this.label = 'Harici bağlantı',
    this.hint = 'https://...',
    this.helperText,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final String? helperText;
  final FormFieldValidator<String>? validator;

  @override
  State<ExternalLinkInput> createState() => _ExternalLinkInputState();
}

class _ExternalLinkInputState extends State<ExternalLinkInput> {
  Future<void> _copy() async {
    final text = widget.controller.text.trim();
    if (text.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bağlantı panoya kopyalandı.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: TextInputType.url,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        helperText: widget.helperText,
        prefixIcon: const Icon(Icons.link_rounded),
        suffixIcon: IconButton(
          tooltip: 'Panoya kopyala',
          icon: const Icon(Icons.copy_rounded),
          onPressed: _copy,
        ),
      ),
    );
  }
}
