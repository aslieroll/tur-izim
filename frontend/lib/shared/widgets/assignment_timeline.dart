import 'package:flutter/material.dart';

import '../models/assignment_timeline_step.dart';

class AssignmentTimeline extends StatelessWidget {
  const AssignmentTimeline({super.key, required this.steps});

  final List<AssignmentTimelineStep> steps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Atama zaman çizelgesi',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...steps.map((s) => _stepTile(context, s)),
          ],
        ),
      ),
    );
  }

  Widget _stepTile(BuildContext context, AssignmentTimelineStep step) {
    final scheme = Theme.of(context).colorScheme;
    final icon = step.isComplete
        ? Icons.check_circle
        : Icons.radio_button_unchecked;
    final color = step.isComplete
        ? scheme.primary
        : scheme.onSurface.withValues(alpha: 0.4);
    final ts = step.timestamp != null
        ? ' · ${_formatUtc(step.timestamp!)}'
        : '';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(step.label),
      subtitle: Text('${step.isComplete ? 'Tamamlandı' : 'Bekliyor'}$ts'),
    );
  }

  static String _formatUtc(DateTime dt) {
    final d = dt.toLocal();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
