class PriceLineItem {
  final String label;
  final double amount;
  final bool isDeduction;

  PriceLineItem({
    required this.label,
    required this.amount,
    this.isDeduction = false,
  });
}

class PriceQuote {
  final double baseRate;
  final double complexityMultiplier;
  final double urgencyMultiplier;
  final double distanceCost;
  final double loyaltyDiscount;
  final double surgeAmount;
  final double finalPrice;
  final double tutorEarning;
  final double platformFee;
  final List<PriceLineItem> breakdown;

  PriceQuote({
    required this.baseRate,
    required this.complexityMultiplier,
    required this.urgencyMultiplier,
    required this.distanceCost,
    required this.loyaltyDiscount,
    required this.surgeAmount,
    required this.finalPrice,
    required this.tutorEarning,
    required this.platformFee,
    required this.breakdown,
  });
}
