import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/leaderboard_entry.dart';
import 'game_manager.dart';

class LeaderboardStorage {
  static const String _leaderboardKey = 'leaderboard_entries';

  static Future<List<LeaderboardEntry>> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final rawEntries = prefs.getStringList(_leaderboardKey) ?? <String>[];

    return rawEntries
        .map((entry) => LeaderboardEntry.fromJson(jsonDecode(entry)))
        .toList();
  }

  static Future<void> saveRun(GameManager gameManager) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await loadEntries();

    // Keep only the strongest runs and prefer older entries for exact score ties.
    entries.add(
      LeaderboardEntry(
        characterName: gameManager.selectedCharacter.name,
        intellect: gameManager.intellect,
        fitness: gameManager.fitness,
        charisma: gameManager.charisma,
        creativity: gameManager.creativity,
        finalScore: gameManager.finalScore,
        rating: gameManager.performanceRating,
        createdAtMillis: DateTime.now().millisecondsSinceEpoch,
      ),
    );

    entries.sort((a, b) {
      final scoreCompare = b.finalScore.compareTo(a.finalScore);
      if (scoreCompare != 0) return scoreCompare;
      return a.createdAtMillis.compareTo(b.createdAtMillis);
    });

    final topEntries = entries.take(10).toList();
    final encodedEntries =
        topEntries.map((entry) => jsonEncode(entry.toJson())).toList();

    await prefs.setStringList(_leaderboardKey, encodedEntries);
  }
}
