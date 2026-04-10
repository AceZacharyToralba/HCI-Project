class CharacterModel {
  final String name;

  // Starting stats
  final int startingIntellect;
  final int startingFitness;
  final int startingCharisma;
  final int startingCreativity;

  // ==========================================================
  // GROWTH RATES (PERCENTAGE)
  // Example: 0.2 = +20%
  // ==========================================================
  final double intellectGrowthRate;
  final double fitnessGrowthRate;
  final double charismaGrowthRate;
  final double creativityGrowthRate;

  // Special trait
  final int restEnergyBonus;

  const CharacterModel({
    required this.name,
    required this.startingIntellect,
    required this.startingFitness,
    required this.startingCharisma,
    required this.startingCreativity,
    required this.intellectGrowthRate,
    required this.fitnessGrowthRate,
    required this.charismaGrowthRate,
    required this.creativityGrowthRate,
    required this.restEnergyBonus,
  });
}