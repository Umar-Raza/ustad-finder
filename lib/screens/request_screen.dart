import 'package:flutter/material.dart';
import 'understanding_screen.dart';

class RequestScreen extends StatefulWidget {
  const RequestScreen({super.key});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  final TextEditingController _controller = TextEditingController();

  final List<String> _examplePrompts = [
    'G-13 mein bachay ke liye math tutor chahiye kal shaam, mehnga na ho',
    'F-11 mein O-level physics ka ustad, urgent',
    'I need an English tutor in I-8 this weekend'
  ];

  void _fillExample(String text) {
    setState(() {
      _controller.text = text;
    });
  }

  void _onFindTutor() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UnderstandingScreen(requestText: text),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Text(
                'Ustad Finder',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'AI-powered tutor matching',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _controller,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Apni request likhein... e.g. G-13 mein math tutor chahiye kal shaam',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _examplePrompts.map((example) {
                  return ActionChip(
                    label: Text(
                      example,
                      style: const TextStyle(fontSize: 12),
                    ),
                    onPressed: () => _fillExample(example),
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    labelStyle: TextStyle(color: theme.colorScheme.onSecondaryContainer),
                  );
                }).toList(),
              ),
              const Spacer(),
              FilledButton(
                onPressed: _onFindTutor,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Find Tutor',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
