import 'package:flutter/material.dart';

import '../game/game_manager.dart';
import '../game/leaderboard_storage.dart';
import 'main_menu.dart';

class ResultScreen extends StatefulWidget {
  final GameManager gameManager;

  const ResultScreen({
    super.key,
    required this.gameManager,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool hasSavedResult = false;

  @override
  void initState() {
    super.initState();
    _saveResultIfNeeded();
  }

  Future<void> _saveResultIfNeeded() async {
    if (hasSavedResult) return;

    hasSavedResult = true;
    await LeaderboardStorage.saveRun(widget.gameManager);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final gameManager = widget.gameManager;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            width: size.width * 0.9,
            padding: EdgeInsets.all(size.width * 0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // =====================================================
                // RESULT TITLE
                // =====================================================
                Text(
                  gameManager.gameWon ? 'YOU WIN!' : 'GAME OVER',
                  style: TextStyle(
                    fontSize: size.width * 0.08,
                    fontWeight: FontWeight.bold,
                    color: gameManager.gameWon ? Colors.green : Colors.red,
                  ),
                ),

                SizedBox(height: size.height * 0.03),

                // =====================================================
                // FINAL STATS TITLE
                // =====================================================
                Text(
                  'Final Stats',
                  style: TextStyle(
                    fontSize: size.width * 0.055,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: size.height * 0.02),

                // =====================================================
                // FINAL STATS
                // =====================================================
                _resultText(size, 'Character: ${gameManager.selectedCharacter.name}'),
                _resultText(size, 'Intellect: ${gameManager.intellect}'),
                _resultText(size, 'Fitness: ${gameManager.fitness}'),
                _resultText(size, 'Charisma: ${gameManager.charisma}'),
                _resultText(size, 'Creativity: ${gameManager.creativity}'),
                _resultText(size, 'Coins: ${gameManager.coins}'),

                SizedBox(height: size.height * 0.03),

                // =====================================================
                // FINAL SCORE
                // =====================================================
                _resultText(size, 'Final Score: ${gameManager.finalScore}'),

                SizedBox(height: size.height * 0.015),

                // =====================================================
                // PERFORMANCE RATING
                // =====================================================
                _resultText(
                  size,
                  'Performance Rating: ${gameManager.performanceRating}',
                ),

                SizedBox(height: size.height * 0.05),

                // =====================================================
                // BACK TO MAIN MENU BUTTON
                // =====================================================
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainMenu(),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text('Back to Main Menu'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =======================================================
  // REUSABLE RESULT TEXT
  // =======================================================
  Widget _resultText(Size size, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: size.height * 0.005),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: size.width * 0.045,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
