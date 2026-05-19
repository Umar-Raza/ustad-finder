import 'dart:math';
import '../models/tutor.dart';
import '../models/match_result.dart';

class MatchingService {
  List<MatchResult> rankTutors(List<Tutor> tutors, Map<String, dynamic> request) {
    if (tutors.isEmpty) return [];

    final String? requestedSubject = request['subject']?.toString().toLowerCase();
    final String? requestedLocation = request['location']?.toString().toUpperCase();
    final String? budgetLevel = request['budgetLevel']?.toString().toLowerCase();

    // Determine min/max rates for price normalization
    double minRate = tutors.map((t) => t.hourlyRate).reduce(min);
    double maxRate = tutors.map((t) => t.hourlyRate).reduce(max);
    if (maxRate == minRate) maxRate = minRate + 1; // Prevent division by zero

    List<MatchResult> results = [];

    for (var tutor in tutors) {
      // 1. Subject Match (Weight: 0.20)
      double subjectMatchScore = 0.0;
      if (requestedSubject != null) {
        bool matches = tutor.subjects.any((s) {
          String sLower = s.toLowerCase();
          return sLower.contains(requestedSubject) || requestedSubject.contains(sLower);
        });
        if (matches) subjectMatchScore = 1.0;
      } else {
        // If no subject requested, assume match to avoid dropping everyone
        subjectMatchScore = 1.0;
      }

      bool isExact = subjectMatchScore == 1.0;

      // 2. Proximity (Weight: 0.15)
      double proximityScore = 0.2; // default
      if (requestedLocation != null) {
        final tutorSector = tutor.sector.toUpperCase();
        if (tutorSector == requestedLocation) {
          proximityScore = 1.0;
        } else if (_isAdjacent(requestedLocation, tutorSector)) {
          proximityScore = 0.5;
        }
      } else {
        proximityScore = 1.0; // If no location requested, don't penalize
      }

      // 3. Rating (Weight: 0.15)
      double ratingScore = tutor.rating / 5.0;

      // 4. Review Recency (Weight: 0.08)
      double reviewRecencyScore = 0.3;
      if (tutor.reviewRecencyDays <= 7) {
        reviewRecencyScore = 1.0;
      } else if (tutor.reviewRecencyDays <= 20) {
        reviewRecencyScore = 0.6;
      }

      // 5. OnTimeScore (Weight: 0.12)
      double onTimeScore = tutor.onTimeScore;

      // 6. Price Fit (Weight: 0.13)
      double priceFitScore = 0.5; // neutral default
      if (budgetLevel == 'low') {
        // Favor lower rates: 1.0 for cheapest, 0.0 for most expensive
        priceFitScore = 1.0 - ((tutor.hourlyRate - minRate) / (maxRate - minRate));
      } else if (budgetLevel == 'high') {
        // Less sensitive, slightly favor higher rates for 'premium' quality
        priceFitScore = (tutor.hourlyRate - minRate) / (maxRate - minRate);
      } else {
        // medium or unspecified
        priceFitScore = 0.8;
      }
      priceFitScore = priceFitScore.clamp(0.0, 1.0);

      // 7. Reliability (Weight: 0.10)
      double reliabilityScore = 1.0 - tutor.cancellationRate;

      // 8. Risk Score (Weight: 0.07)
      double riskScore = 1.0 - tutor.riskScore;

      // Apply weights and populate breakdown map
      final Map<String, double> breakdown = {
        'subjectMatch': subjectMatchScore * 0.20,
        'proximity': proximityScore * 0.15,
        'rating': ratingScore * 0.15,
        'reviewRecency': reviewRecencyScore * 0.08,
        'onTimeScore': onTimeScore * 0.12,
        'priceFit': priceFitScore * 0.13,
        'reliability': reliabilityScore * 0.10,
        'riskScore': riskScore * 0.07,
      };

      // Sum factors and map to 100 point scale
      double totalScore = breakdown.values.fold(0.0, (sum, val) => sum + val) * 100;

      results.add(MatchResult(
        tutor: tutor,
        totalScore: totalScore,
        factorBreakdown: breakdown,
        isExactSubjectMatch: isExact,
      ));
    }

    // Sort descending by totalScore
    results.sort((a, b) => b.totalScore.compareTo(a.totalScore));
    return results;
  }

  // Simple hardcoded adjacency map for demonstration
  bool _isAdjacent(String s1, String s2) {
    const Map<String, List<String>> adjacencies = {
      'G-13': ['G-12', 'G-14', 'F-13', 'H-13'],
      'F-11': ['F-10', 'F-12', 'E-11', 'G-11'],
      'I-8':  ['I-9', 'I-7', 'H-8', 'J-8'],
    };
    
    return (adjacencies[s1]?.contains(s2) ?? false) || 
           (adjacencies[s2]?.contains(s1) ?? false);
  }
}
