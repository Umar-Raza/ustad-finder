import 'package:flutter/material.dart';
import '../models/tutor.dart';
import '../models/price_quote.dart';
import '../services/pricing_service.dart';
import '../widgets/agent_reasoning_panel.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'booking_screen.dart';

class PricingScreen extends StatefulWidget {
  final Tutor tutor;
  final Map<String, dynamic> request;

  const PricingScreen({
    super.key,
    required this.tutor,
    required this.request,
  });

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  late final PriceQuote quote;
  late final List<String> reasoningSteps;

  @override
  void initState() {
    super.initState();
    final pricingService = PricingService();
    quote = pricingService.generateQuote(widget.tutor, widget.request);

    // Generate Agent Reasoning Steps
    reasoningSteps = [
      'Calculating fair price for ${widget.tutor.name}',
      'Base rate Rs ${quote.baseRate.toStringAsFixed(0)}/hr',
    ];

    if (quote.complexityMultiplier != 1.0) {
      reasoningSteps.add('Complexity adjustment for ${widget.tutor.specialization} (x${quote.complexityMultiplier})');
    }

    if (quote.surgeAmount > 0) {
      reasoningSteps.add('Urgency surcharge applied (high demand)');
    }

    if (quote.distanceCost > 0) {
      reasoningSteps.add('Distance surcharge applied for cross-sector travel');
    }

    if (quote.loyaltyDiscount > 0) {
      reasoningSteps.add('Loyalty discount Rs ${quote.loyaltyDiscount.toStringAsFixed(0)} applied');
    }

    reasoningSteps.add('Final transparent quote ready');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transparent Quote'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Agent Reasoning Panel
            AgentReasoningPanel(
              title: 'Antigravity AI Pricing Engine',
              reasoningSteps: reasoningSteps,
            ),
            const SizedBox(height: 24),

            // Price Breakdown Card
            _buildPriceBreakdownCard(theme),
            const SizedBox(height: 24),

            // Fairness View Card
            _buildFairnessViewCard(theme),
            const SizedBox(height: 32),

            // Confirm Booking Button
            FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingScreen(
                      tutor: widget.tutor,
                      request: widget.request,
                      finalPrice: quote.finalPrice,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Confirm Booking', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ).animate().slideY(begin: 0.5, end: 0, duration: 400.ms, curve: Curves.easeOut).fadeIn(),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceBreakdownCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price Breakdown',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            ...quote.breakdown.map((item) {
              final isDed = item.isDeduction;
              final amountStr = 'Rs ${item.amount.toStringAsFixed(0)}';
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.label,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      isDed ? '- $amountStr' : '+ $amountStr',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDed ? Colors.green.shade700 : null,
                        fontWeight: isDed ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const Divider(height: 24, thickness: 1.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Final Total',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Rs ${quote.finalPrice.toStringAsFixed(0)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildFairnessViewCard(ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.handshake_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Fairness View',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('You Pay', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                        const SizedBox(height: 4),
                        Text(
                          'Rs ${quote.finalPrice.toStringAsFixed(0)}',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tutor Earns', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                        const SizedBox(height: 4),
                        Text(
                          'Rs ${quote.tutorEarning.toStringAsFixed(0)}',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'A platform fee of Rs ${quote.platformFee.toStringAsFixed(0)} (12%) helps us keep Ustad Finder running smoothly.',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.1, end: 0);
  }
}
