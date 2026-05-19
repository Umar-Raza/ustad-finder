import 'package:flutter/material.dart';
import '../models/tutor.dart';
import '../models/match_result.dart';
import '../services/data_service.dart';
import '../services/matching_service.dart';
import '../widgets/agent_reasoning_panel.dart';
import 'pricing_screen.dart';

class MatchingScreen extends StatefulWidget {
  final Map<String, dynamic> request;

  const MatchingScreen({super.key, required this.request});

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  final DataService _dataService = DataService();
  final MatchingService _matchingService = MatchingService();

  bool _isLoading = true;
  List<MatchResult> _matches = [];
  int _totalTutors = 0;

  @override
  void initState() {
    super.initState();
    _loadAndMatch();
  }

  Future<void> _loadAndMatch() async {
    final allTutors = await _dataService.loadTutors();
    _totalTutors = allTutors.length;
    
    final ranked = _matchingService.rankTutors(allTutors, widget.request);
    
    setState(() {
      _matches = ranked;
      _isLoading = false;
    });
  }

  List<String> _generateReasoningSteps() {
    final subject = widget.request['subject']?.toString() ?? 'Any';
    
    final steps = [
      'Evaluating $_totalTutors tutors across 8 factors',
      'Filtering by subject: $subject',
      '${_matches.length} tutors qualify',
      'Ranking by weighted score (not distance alone)',
    ];

    if (_matches.isNotEmpty) {
      steps.add('Top match: ${_matches.first.tutor.name} with score ${_matches.first.totalScore.toStringAsFixed(1)}');
    } else {
      steps.add('No tutors met the strict requirements.');
    }

    return steps;
  }

  Widget _buildFactorBar(String label, double weightedValue, double maxWeight) {
    final normalized = (weightedValue / maxWeight).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(label, style: const TextStyle(fontSize: 12))),
          Expanded(
            child: LinearProgressIndicator(
              value: normalized,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 45,
            child: Text('${(weightedValue * 100).toStringAsFixed(1)}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdown(Map<String, double> breakdown) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFactorBar('Subject', breakdown['subjectMatch'] ?? 0, 0.20),
        _buildFactorBar('Proximity', breakdown['proximity'] ?? 0, 0.15),
        _buildFactorBar('Rating', breakdown['rating'] ?? 0, 0.15),
        _buildFactorBar('Review Recency', breakdown['reviewRecency'] ?? 0, 0.08),
        _buildFactorBar('On-Time', breakdown['onTimeScore'] ?? 0, 0.12),
        _buildFactorBar('Price Fit', breakdown['priceFit'] ?? 0, 0.13),
        _buildFactorBar('Reliability', breakdown['reliability'] ?? 0, 0.10),
        _buildFactorBar('Low Risk', breakdown['riskScore'] ?? 0, 0.07),
      ],
    );
  }

  Widget _buildMatchCard(MatchResult match, int rank) {
    final tutor = match.tutor;
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PricingScreen(tutor: tutor, request: widget.request),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: rank == 1 ? Colors.amber : theme.colorScheme.primaryContainer,
                    foregroundColor: rank == 1 ? Colors.black87 : theme.colorScheme.onPrimaryContainer,
                    child: Text('#$rank', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tutor.name,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${tutor.subjects.join(", ")} • ${tutor.sector}',
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text('${tutor.rating} (${tutor.reviews})'),
                            const SizedBox(width: 16),
                            const Icon(Icons.payments_outlined, size: 16),
                            const SizedBox(width: 4),
                            Text('Rs ${tutor.hourlyRate}/hr'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        match.totalScore.toStringAsFixed(1),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text('Score', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Theme(
                data: theme.copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: const Text('Why this ranking?', style: TextStyle(fontSize: 14)),
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(bottom: 8.0),
                  children: [
                    _buildBreakdown(match.factorBreakdown),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Matched Tutors')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AgentReasoningPanel(
                    title: 'Ranking Engine Execution:',
                    reasoningSteps: _generateReasoningSteps(),
                  ),
                  const SizedBox(height: 24),
                  if (_matches.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('No tutors match the required subject.'),
                      ),
                    )
                  else
                    ..._matches.asMap().entries.map((e) => _buildMatchCard(e.value, e.key + 1)),
                ],
              ),
            ),
    );
  }
}
