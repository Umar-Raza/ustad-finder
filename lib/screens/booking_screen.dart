import 'package:flutter/material.dart';
import 'dart:math';
import '../models/tutor.dart';
import '../widgets/agent_reasoning_panel.dart';
import 'service_loop_screen.dart';

class BookingScreen extends StatefulWidget {
  final Tutor tutor;
  final Map<String, dynamic> request;
  final double finalPrice;

  const BookingScreen({
    super.key,
    required this.tutor,
    required this.request,
    required this.finalPrice,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late final String _bookingId;

  @override
  void initState() {
    super.initState();
    // Generate random booking ID: UF-2026-XXXX
    final rand = Random().nextInt(9000) + 1000;
    _bookingId = 'UF-2026-$rand';
  }

  List<String> _generateReasoningSteps() {
    final preferredTime = widget.request['preferredTime']?.toString() ?? 'requested time';
    return [
      'Checking ${widget.tutor.name} availability for $preferredTime',
      'No scheduling conflict found',
      'Slot reserved with 30-min travel buffer',
      'Generating confirmation & receipt',
      'Notification dispatched',
    ];
  }

  Widget _buildSuccessCard(ThemeData theme) {
    final preferredTime = widget.request['preferredTime']?.toString() ?? 'TBD';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            Text('Booking Confirmed!', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildDetailRow('Booking ID', _bookingId, theme),
            _buildDetailRow('Tutor', widget.tutor.name, theme),
            _buildDetailRow('Time Slot', preferredTime, theme),
            _buildDetailRow('Total Price', 'Rs ${widget.finalPrice.toStringAsFixed(0)}', theme, isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? theme.colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(ThemeData theme) {
    final preferredTime = widget.request['preferredTime']?.toString() ?? 'TBD';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Simulated Notification', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFDCF8C6), // WhatsApp light green tint
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.message, color: Color(0xFF075E54), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Ustad Finder: Aapki booking confirm ho gayi hai! $_bookingId\n\nTutor: ${widget.tutor.name}\nTime: $preferredTime\nAmount: Rs ${widget.finalPrice.toStringAsFixed(0)}\n\nTutor jald hi aap se raabta karenge.',
                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptCard(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Digital Receipt', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Session Fee', 'Rs ${widget.tutor.hourlyRate}', theme),
            _buildDetailRow('Platform Fee', 'Rs ${(widget.finalPrice - widget.tutor.hourlyRate).toStringAsFixed(0)}', theme),
            const Divider(),
            _buildDetailRow('Total Charged', 'Rs ${widget.finalPrice.toStringAsFixed(0)}', theme, isBold: true),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Confirmation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AgentReasoningPanel(
              title: 'Automated Booking Agent:',
              reasoningSteps: _generateReasoningSteps(),
            ),
            const SizedBox(height: 24),
            _buildSuccessCard(theme),
            const SizedBox(height: 24),
            _buildNotificationCard(theme),
            const SizedBox(height: 24),
            _buildReceiptCard(theme),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ServiceLoopScreen(
                      bookingId: _bookingId,
                      tutor: widget.tutor,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Session Tracking'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
