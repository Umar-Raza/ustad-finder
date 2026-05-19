import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AgentReasoningPanel extends StatelessWidget {
  final String title;
  final List<String> reasoningSteps;

  const AgentReasoningPanel({
    super.key,
    required this.title,
    required this.reasoningSteps,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Soft indigo tint background
    final indigoTint = theme.colorScheme.primary.withValues(alpha: 0.08);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: indigoTint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🧠', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'Agent Reasoning',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          if (title.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 16),
          ...reasoningSteps.asMap().entries.map((entry) {
            int idx = entry.key;
            String step = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${idx + 1}. ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      step,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ).animate()
             .fadeIn(duration: 400.ms, delay: (idx * 200).ms)
             .slideX(begin: 0.05, end: 0, duration: 400.ms, curve: Curves.easeOut);
          }),
        ],
      ),
    );
  }
}
