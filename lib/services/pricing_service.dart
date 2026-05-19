import '../models/tutor.dart';
import '../models/price_quote.dart';

class PricingService {
  PriceQuote generateQuote(Tutor tutor, Map<String, dynamic> request) {
    double baseRate = tutor.hourlyRate;

    // 1. Complexity Multiplier
    double complexityMultiplier = 1.0;
    final String specialization = (tutor.specialization).toLowerCase();
    final String reqSubject = (request['subject']?.toString() ?? '').toLowerCase();
    
    if (specialization.contains('o/a levels') || 
        specialization.contains('university') ||
        reqSubject.contains('university') ||
        reqSubject.contains('o level') ||
        reqSubject.contains('a level')) {
      complexityMultiplier = 1.3;
    } else if (specialization.contains('matric') || 
               specialization.contains('fsc') || 
               specialization.contains('f.sc') ||
               reqSubject.contains('matric') ||
               reqSubject.contains('fsc')) {
      complexityMultiplier = 1.15;
    } else if (specialization.contains('primary') || reqSubject.contains('primary')) {
      complexityMultiplier = 1.0;
    }

    // 2. Urgency Multiplier & Surge Amount
    double urgencyMultiplier = 1.0;
    double surgeAmount = 0.0;
    final String urgency = (request['urgency']?.toString() ?? '').toLowerCase();
    
    if (urgency == 'high') {
      urgencyMultiplier = 1.25;
      surgeAmount = baseRate * 0.10; // +10% of base rate
    } else if (urgency == 'medium') {
      urgencyMultiplier = 1.1;
    } else {
      urgencyMultiplier = 1.0;
    }

    // 3. Distance Cost
    double distanceCost = 0.0;
    final String reqLocation = (request['location']?.toString() ?? '').toLowerCase();
    final String tutorSector = tutor.sector.toLowerCase();
    
    if (reqLocation.isNotEmpty && reqLocation != tutorSector) {
      distanceCost = 150.0;
    }

    // 4. Loyalty Discount
    double loyaltyDiscount = 100.0; // flat 100

    // 5. Final Price Calculation
    double calculatedPrice = (baseRate * complexityMultiplier * urgencyMultiplier) + distanceCost + surgeAmount - loyaltyDiscount;
    double finalPrice = calculatedPrice > 0 ? calculatedPrice : 0.0;

    // 6. Platform Fee & Tutor Earning
    double platformFee = finalPrice * 0.12;
    double tutorEarning = finalPrice - platformFee;

    // 7. Build Breakdown
    List<PriceLineItem> breakdown = [];
    
    breakdown.add(PriceLineItem(
      label: 'Base Rate (${tutor.name})', 
      amount: baseRate,
    ));

    if (complexityMultiplier != 1.0) {
      double complexityExtra = (baseRate * complexityMultiplier) - baseRate;
      breakdown.add(PriceLineItem(
        label: 'Complexity Adjustment (x$complexityMultiplier)', 
        amount: complexityExtra,
      ));
    }

    if (urgencyMultiplier != 1.0) {
      double currentBase = baseRate * complexityMultiplier;
      double urgencyExtra = (currentBase * urgencyMultiplier) - currentBase;
      breakdown.add(PriceLineItem(
        label: 'Urgency Adjustment (x$urgencyMultiplier)', 
        amount: urgencyExtra,
      ));
    }

    if (surgeAmount > 0) {
      breakdown.add(PriceLineItem(
        label: 'Peak Surge (10%)', 
        amount: surgeAmount,
      ));
    }

    if (distanceCost > 0) {
      breakdown.add(PriceLineItem(
        label: 'Distance Surcharge (Different Sector)', 
        amount: distanceCost,
      ));
    }

    if (loyaltyDiscount > 0) {
      breakdown.add(PriceLineItem(
        label: 'Loyalty Discount', 
        amount: loyaltyDiscount,
        isDeduction: true,
      ));
    }

    return PriceQuote(
      baseRate: baseRate,
      complexityMultiplier: complexityMultiplier,
      urgencyMultiplier: urgencyMultiplier,
      distanceCost: distanceCost,
      loyaltyDiscount: loyaltyDiscount,
      surgeAmount: surgeAmount,
      finalPrice: finalPrice,
      tutorEarning: tutorEarning,
      platformFee: platformFee,
      breakdown: breakdown,
    );
  }
}
