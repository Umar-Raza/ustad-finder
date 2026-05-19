import 'tutor.dart';

class MatchResult {
  final Tutor tutor;
  final double totalScore; // 0 to 100
  final Map<String, double> factorBreakdown; // Each factor's weighted contribution

  MatchResult({
    required this.tutor,
    required this.totalScore,
    required this.factorBreakdown,
  });
}
