import 'package:flutter/material.dart';
import '../widgets/agent_reasoning_panel.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DisputeScreen extends StatefulWidget {
  const DisputeScreen({super.key});

  @override
  State<DisputeScreen> createState() => _DisputeScreenState();
}

class _DisputeScreenState extends State<DisputeScreen> {
  String? _selectedDispute;
  bool _isResolving = false;
  bool _isResolved = false;

  final List<String> _disputeTypes = [
    'No-show',
    'Quality complaint',
    'Price disagreement',
    'Late arrival',
  ];

  void _onResolve() {
    if (_selectedDispute == null) return;
    
    setState(() {
      _isResolving = true;
      _isResolved = false;
    });

    // Simulate AI Agent processing delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isResolving = false;
          _isResolved = true;
        });
      }
    });
  }

  List<String> _getReasoningSteps() {
    switch (_selectedDispute) {
      case 'No-show':
        return [
          'Verifying booking record & GPS logs...',
          'Provider failed to attend.',
          'Issuing full refund of Rs 1500.',
          'Provider reliability score heavily reduced (-10 pts).',
          'Auto-rematching alternate tutor for tomorrow.',
          'Escalation: Not required. Auto-resolved.',
        ];
      case 'Quality complaint':
        return [
          'Analyzing session duration and feedback NLP...',
          'Sentiment analysis flags dissatisfaction.',
          'Checking tutor historical performance (Rating: 4.8).',
          'First offense detected for this tutor.',
          'Issuing 30% partial refund.',
          'Escalation: Flagged for human review.',
        ];
      case 'Price disagreement':
        return [
          'Comparing charged amount vs agreed quote...',
          'Quote was Rs 1200, charge was Rs 1500.',
          'Discrepancy detected.',
          'Automatically adjusting final bill to match quote.',
          'Refunding difference (Rs 300) to wallet.',
          'Escalation: Not required.',
        ];
      case 'Late arrival':
        return [
          'Cross-referencing GPS arrival time with scheduled time...',
          'Tutor arrived 25 minutes late.',
          'Applying late-arrival penalty policy.',
          'Issuing 15% discount for the inconvenience.',
          'Tutor On-Time Score reduced.',
          'Escalation: Not required.',
        ];
      default:
        return [];
    }
  }

  Widget _buildResolutionCard(ThemeData theme) {
    IconData icon;
    Color color;
    String title;
    String description;

    switch (_selectedDispute) {
      case 'No-show':
        icon = Icons.published_with_changes;
        color = Colors.blue;
        title = 'Full Refund & Auto-Rematch';
        description = 'A full refund has been initiated to your original payment method. We are assigning a new tutor for your next available slot.';
        break;
      case 'Quality complaint':
        icon = Icons.support_agent;
        color = Colors.orange;
        title = 'Partial Refund & Human Review';
        description = 'A 30% refund has been credited. The case has been escalated to our Quality Assurance team for manual review.';
        break;
      case 'Price disagreement':
        icon = Icons.account_balance_wallet;
        color = Colors.green;
        title = 'Price Adjusted';
        description = 'The extra Rs 300 charged has been automatically refunded to your wallet to match the original agreed quote.';
        break;
      case 'Late arrival':
        icon = Icons.timer_off;
        color = Colors.purple;
        title = 'Late Penalty Applied';
        description = 'A 15% discount has been applied to this session as compensation for the tutor\'s late arrival.';
        break;
      default:
        icon = Icons.check_circle;
        color = Colors.green;
        title = 'Resolved';
        description = 'The issue has been resolved automatically.';
    }

    return Card(
      elevation: 4,
      shadowColor: color.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(icon, size: 56, color: color),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Dispute Resolution Center')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'What went wrong?',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text('Select dispute type'),
                  value: _selectedDispute,
                  items: _disputeTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedDispute = val;
                      _isResolved = false;
                      _isResolving = false;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: (_selectedDispute == null || _isResolving) ? null : _onResolve,
              icon: _isResolving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(_isResolving ? 'AI is Analyzing...' : 'Auto-Resolve Issue'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 32),
            
            if (_isResolved && _selectedDispute != null) ...[
              AgentReasoningPanel(
                title: 'AI Dispute Resolution Agent:',
                reasoningSteps: _getReasoningSteps(),
              ),
              const SizedBox(height: 24),
              _buildResolutionCard(theme),
            ]
          ],
        ),
      ),
    );
  }
}
