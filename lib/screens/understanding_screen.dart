import 'package:flutter/material.dart';
import '../services/gemini_service.dart';
import '../widgets/agent_reasoning_panel.dart';
import 'matching_screen.dart';

class UnderstandingScreen extends StatefulWidget {
  final String requestText;

  const UnderstandingScreen({super.key, required this.requestText});

  @override
  State<UnderstandingScreen> createState() => _UnderstandingScreenState();
}

class _UnderstandingScreenState extends State<UnderstandingScreen> {
  late final GeminiService _geminiService;
  final TextEditingController _refineController = TextEditingController();

  bool _isLoading = true;
  bool _hasError = false;
  Map<String, dynamic>? _parsedData;
  String _currentInput = "";

  @override
  void initState() {
    super.initState();
    _geminiService = GeminiService();
    _currentInput = widget.requestText;
    _parseRequest();
  }

  @override
  void dispose() {
    _refineController.dispose();
    super.dispose();
  }

  Future<void> _parseRequest() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final result = await _geminiService.parseRequest(_currentInput);
      
      // Basic validation if fallback happened
      if (result['confidenceScore'] == 0.0 && result['subject'] == null && result['location'] == null) {
        _hasError = true;
      }
      
      setState(() {
        _parsedData = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _onConfirmRefinement() {
    final extraText = _refineController.text.trim();
    if (extraText.isNotEmpty) {
      // Append the new clarification to the context
      _currentInput = "$_currentInput. User clarification: $extraText";
      _refineController.clear();
      _parseRequest();
    }
  }

  void _onFindMatches() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MatchingScreen(request: _parsedData!),
      ),
    );
  }

  List<String> _generateReasoningSteps(Map<String, dynamic> data) {
    final steps = <String>['Input language detected: mixed Urdu/English/Roman Urdu'];
    
    if (data['subject'] != null) {
      steps.add('Extracted subject: ${data['subject']}');
    }
    if (data['location'] != null) {
      steps.add('Identified location: ${data['location']}');
    }
    if (data['urgency'] != null) {
      steps.add('Assessed urgency: ${data['urgency']}');
    }
    if (data['budgetLevel'] != null) {
      steps.add('Budget preference: ${data['budgetLevel']}');
    }
    
    final conf = (data['confidenceScore'] as num?)?.toDouble() ?? 0.0;
    steps.add('Confidence Score: ${conf.toStringAsFixed(2)}');
    
    return steps;
  }

  Widget _buildFieldChip(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return InputChip(
      label: Text('$label: $value'),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
      isEnabled: false,
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              'Agent samajh raha hai...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    if (_hasError || _parsedData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Oops! Kuch samajh nahi aaya. Dobara koshish karein?'),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _parseRequest,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final data = _parsedData!;
    final needsConfirmation = data['needsConfirmation'] == true;
    final confidenceScore = (data['confidenceScore'] as num?)?.toDouble() ?? 0.0;
    final requiresRefinement = needsConfirmation || confidenceScore < 0.6;
    final question = data['confirmationQuestion'] as String?;
    
    final constraints = data['constraints'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AgentReasoningPanel(
            title: 'I have processed your request:',
            reasoningSteps: _generateReasoningSteps(data),
          ),
          const SizedBox(height: 24),
          
          Text(
            'Extracted Requirements',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              _buildFieldChip('Subject', data['subject']?.toString()),
              _buildFieldChip('Location', data['location']?.toString()),
              _buildFieldChip('Urgency', data['urgency']?.toString()),
              _buildFieldChip('Time', data['preferredTime']?.toString()),
              _buildFieldChip('Budget', data['budgetLevel']?.toString()),
              for (var c in constraints)
                _buildFieldChip('Constraint', c.toString()),
            ],
          ),
          
          const SizedBox(height: 32),
          
          if (requiresRefinement) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.help_outline, color: Theme.of(context).colorScheme.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          question ?? 'Please provide more details.',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _refineController,
                    decoration: const InputDecoration(
                      hintText: 'Add more details...',
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _onConfirmRefinement,
                    icon: const Icon(Icons.check),
                    label: const Text('Confirm'),
                  ),
                ],
              ),
            ),
          ] else ...[
            FilledButton(
              onPressed: _onFindMatches,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(20),
              ),
              child: const Text(
                'Find Matching Tutors',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Processing Request'),
      ),
      body: _buildContent(context),
    );
  }
}
