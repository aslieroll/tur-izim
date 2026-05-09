import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// URL girişi + panoya kopyalama (harici paket gerektirmeden paylaşım).
class UrlFieldWithOpen extends StatefulWidget {
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
  State<UrlFieldWithOpen> createState() => _UrlFieldWithOpenState();
}

class _UrlFieldWithOpenState extends State<UrlFieldWithOpen> {
  Future<void> _copy() async {
    final text = widget.controller.text.trim();
    if (text.isEmpty) {
      return;
    }
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
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        suffixIcon: IconButton(
          tooltip: 'Panoya kopyala',
          icon: const Icon(Icons.copy),
          onPressed: _copy,
        ),
      ),
      keyboardType: TextInputType.url,
      validator: widget.validator,
    );
  }
}
