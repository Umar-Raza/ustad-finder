class Tutor {
  final String id;
  final String name;
  final List<String> subjects;
  final String sector;
  final double lat;
  final double lng;
  final double rating;
  final int reviews;
  final int reviewRecencyDays;
  final double onTimeScore;
  final double hourlyRate;
  final int experienceYears;
  final String specialization;
  final double cancellationRate;
  final List<String> availableSlots;
  final double riskScore;
  final int completedJobs;

  Tutor({
    required this.id,
    required this.name,
    required this.subjects,
    required this.sector,
    required this.lat,
    required this.lng,
    required this.rating,
    required this.reviews,
    required this.reviewRecencyDays,
    required this.onTimeScore,
    required this.hourlyRate,
    required this.experienceYears,
    required this.specialization,
    required this.cancellationRate,
    required this.availableSlots,
    required this.riskScore,
    required this.completedJobs,
  });

  factory Tutor.fromJson(Map<String, dynamic> json) {
    return Tutor(
      id: json['id'] as String,
      name: json['name'] as String,
      subjects: List<String>.from(json['subjects'] ?? []),
      sector: json['sector'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      reviews: json['reviews'] as int,
      reviewRecencyDays: json['reviewRecencyDays'] as int,
      onTimeScore: (json['onTimeScore'] as num).toDouble(),
      hourlyRate: (json['hourlyRate'] as num).toDouble(),
      experienceYears: json['experienceYears'] as int,
      specialization: json['specialization'] as String,
      cancellationRate: (json['cancellationRate'] as num).toDouble(),
      availableSlots: List<String>.from(json['availableSlots'] ?? []),
      riskScore: (json['riskScore'] as num).toDouble(),
      completedJobs: json['completedJobs'] as int,
    );
  }
}
