import 'package:flutter/material.dart';
import '../models/tutor.dart';
import '../widgets/agent_reasoning_panel.dart';
import 'dispute_screen.dart';

class ServiceLoopScreen extends StatefulWidget {
  final String bookingId;
  final Tutor tutor;

  const ServiceLoopScreen({super.key, required this.bookingId, required this.tutor});

  @override
  State<ServiceLoopScreen> createState() => _ServiceLoopScreenState();
}

class _ServiceLoopScreenState extends State<ServiceLoopScreen> {
  int _currentStep = 0;
  bool _feedbackSubmitted = false;
  int _selectedRating = 5;
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _submitFeedback() {
    setState(() {
      _feedbackSubmitted = true;
    });
  }

  List<String> _getAgentReasoning() {
    switch (_currentStep) {
      case 0:
        return [
          'Tracking GPS coordinates of ${widget.tutor.name}',
          'Traffic is light. ETA is 14 minutes.',
          'Calculating safe route...',
        ];
      case 1:
        return [
          'GPS confirms arrival at location.',
          'Start time logged automatically.',
          'Monitoring session duration.',
        ];
      case 2:
        if (_feedbackSubmitted) {
          return [
            'Analyzing feedback text via NLP...',
            'Sentiment is positive.',
            'Updating ${widget.tutor.name}\'s profile ranking globally.',
          ];
        }
        return [
          'Session duration reached.',
          'Payment authorized.',
          'Waiting for user feedback.',
        ];
      default:
        return [];
    }
  }

  Widget _buildFeedbackSection(ThemeData theme) {
    if (_feedbackSubmitted) {
      return Card(
        color: theme.colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(Icons.stars, color: theme.colorScheme.onPrimaryContainer, size: 48),
              const SizedBox(height: 16),
              Text(
                'Reputation Updated',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.tutor.name}\'s rating has been recalculated. Future match scores for this tutor will be adjusted accordingly.',
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Rate your session', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _selectedRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedRating = index + 1;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _feedbackController,
              decoration: const InputDecoration(
                hintText: 'Leave a comment...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _submitFeedback,
              child: const Text('Submit Feedback'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Session Tracking')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Booking ID: ${widget.bookingId}', style: theme.textTheme.labelLarge),
            const SizedBox(height: 16),
            
            AgentReasoningPanel(
              title: 'Automated Operations Agent:',
              reasoningSteps: _getAgentReasoning(),
            ),
            const SizedBox(height: 24),

            Stepper(
              physics: const NeverScrollableScrollPhysics(),
              currentStep: _currentStep,
              onStepContinue: _currentStep < 2 ? _nextStep : null,
              onStepCancel: null,
              controlsBuilder: (BuildContext context, ControlsDetails details) {
                if (_currentStep == 2) return const SizedBox.shrink(); // Hide Next button on last step
                return Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: FilledButton(
                    onPressed: details.onStepContinue,
                    child: const Text('Simulate Next Stage'),
                  ),
                );
              },
              steps: [
                Step(
                  title: const Text('Tutor en-route'),
                  subtitle: const Text('ETA: 14 mins'),
                  content: const Text('Tutor is travelling to your location.'),
                  isActive: _currentStep >= 0,
                  state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                ),
                Step(
                  title: const Text('Session started'),
                  content: const Text('Session is currently in progress.'),
                  isActive: _currentStep >= 1,
                  state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                ),
                Step(
                  title: const Text('Session completed'),
                  content: const Text('Session has ended successfully.'),
                  isActive: _currentStep >= 2,
                  state: _currentStep == 2 ? StepState.complete : StepState.indexed,
                ),
              ],
            ),

            if (_currentStep == 2) ...[
              const SizedBox(height: 24),
              _buildFeedbackSection(theme),
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DisputeScreen()),
                  );
                },
                icon: const Icon(Icons.warning_amber_rounded, color: Colors.red),
                label: const Text('Report an Issue', style: TextStyle(color: Colors.red)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
