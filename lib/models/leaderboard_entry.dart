class LeaderboardEntry {
  final String characterName;
  final int intellect;
  final int fitness;
  final int charisma;
  final int creativity;
  final int finalScore;
  final String rating;
  final int createdAtMillis;

  const LeaderboardEntry({
    required this.characterName,
    required this.intellect,
    required this.fitness,
    required this.charisma,
    required this.creativity,
    required this.finalScore,
    required this.rating,
    required this.createdAtMillis,
  });

  Map<String, dynamic> toJson() {
    return {
      'characterName': characterName,
      'intellect': intellect,
      'fitness': fitness,
      'charisma': charisma,
      'creativity': creativity,
      'finalScore': finalScore,
      'rating': rating,
      'createdAtMillis': createdAtMillis,
    };
  }

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      characterName: json['characterName'] as String? ?? 'Unknown',
      intellect: json['intellect'] as int? ?? 0,
      fitness: json['fitness'] as int? ?? 0,
      charisma: json['charisma'] as int? ?? 0,
      creativity: json['creativity'] as int? ?? 0,
      finalScore: json['finalScore'] as int? ?? 0,
      rating: json['rating'] as String? ?? 'C',
      createdAtMillis: json['createdAtMillis'] as int? ?? 0,
    );
  }
}
