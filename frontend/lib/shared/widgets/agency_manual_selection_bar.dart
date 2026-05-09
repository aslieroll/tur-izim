import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

class AgencyManualSelectionBar extends StatelessWidget {
  const AgencyManualSelectionBar({
    super.key,
    required this.quota,
    required this.selectedCount,
    required this.remainingSlots,
    required this.onConfirm,
  });

  final int quota;
  final int selectedCount;
  final int remainingSlots;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final disabled = selectedCount == 0 || remainingSlots <= 0;
    final theme = Theme.of(context);

    return Material(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kota $quota · Seçilen: $selectedCount · Müsait: $remainingSlots',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: disabled ? null : onConfirm,
                child: SizedBox(
                  height: AppConstants.minTouchTarget,
                  child: const Center(
                    child: Text('Seçilen başvuruları onayla'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
