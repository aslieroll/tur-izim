import 'package:flutter/material.dart';

/// Birincil CTA — tema `ElevatedButton` stillerini kullanır; iş mantığı yok.
class TurIzimPrimaryButton extends StatelessWidget {
  const TurIzimPrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
