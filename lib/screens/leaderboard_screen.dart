import 'dart:async';

import 'package:flutter/material.dart';

import '../game/audio_manager.dart';
import '../game/leaderboard_storage.dart';
import '../models/leaderboard_entry.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final AudioManager audioManager = AudioManager.instance;

  @override
  void initState() {
    super.initState();

    unawaited(_prepareAudio());
  }

  Future<void> _prepareAudio() async {
    await audioManager.init();
    if (!mounted) return;
    await audioManager.playLeaderboardBgm();
  }

  @override
  void dispose() {
    unawaited(audioManager.playMainMenuBgm());
    super.dispose();
  }

  void _goBack() {
    audioManager.playButtonClick();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF507FA6),
                    Color(0xFF22384E),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -size.width * 0.2,
            left: -size.width * 0.1,
            child: Container(
              width: size.width * 0.5,
              height: size.width * 0.5,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    size.width * 0.05,
                    size.height * 0.025,
                    size.width * 0.05,
                    size.height * 0.015,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: size.height * 0.12,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            'assets/gameplay screeen/Pause Panel.png',
                            fit: BoxFit.fill,
                            filterQuality: FilterQuality.none,
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Hall of',
                                style: TextStyle(
                                  fontSize: size.width * 0.04,
                                  color: Colors.brown.shade900,
                                ),
                              ),
                              Text(
                                'Top Scholars',
                                style: TextStyle(
                                  fontSize: size.width * 0.065,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<LeaderboardEntry>>(
                    future: LeaderboardStorage.loadEntries(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final entries = snapshot.data ?? <LeaderboardEntry>[];

                      if (entries.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(size.width * 0.08),
                            child: _buildContentPanel(
                              size: size,
                              child: Center(
                                child: Text(
                                  'No runs recorded yet.\nFinish a game to place your first scholar here.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: size.width * 0.048,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.brown.shade900,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: EdgeInsets.fromLTRB(
                          size.width * 0.05,
                          size.height * 0.01,
                          size.width * 0.05,
                          size.height * 0.02,
                        ),
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          final entry = entries[index];

                          return Padding(
                            padding: EdgeInsets.only(bottom: size.height * 0.018),
                            child: _buildEntryCard(
                              size: size,
                              index: index,
                              entry: entry,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: size.width * 0.1,
                    right: size.width * 0.1,
                    bottom: size.height * 0.03,
                  ),
                  child: GestureDetector(
                    onTap: _goBack,
                    child: SizedBox(
                      width: size.width * 0.42,
                      height: size.height * 0.075,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned.fill(
                            child: Image.asset(
                              'assets/gameplay screeen/Pause Inner Buttons.png',
                              fit: BoxFit.fill,
                              filterQuality: FilterQuality.none,
                            ),
                          ),
                          Text(
                            'RETURN',
                            style: TextStyle(
                              fontSize: size.width * 0.042,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              shadows: const [
                                Shadow(color: Colors.white, blurRadius: 6),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentPanel({
    required Size size,
    required Widget child,
  }) {
    return SizedBox(
      width: double.infinity,
      height: size.height * 0.58,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/gameplay screeen/Store Panel.png',
              fit: BoxFit.fill,
              filterQuality: FilterQuality.none,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(size.width * 0.07),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard({
    required Size size,
    required int index,
    required LeaderboardEntry entry,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/gameplay screeen/Event Panel.png',
              fit: BoxFit.fill,
              filterQuality: FilterQuality.none,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.06,
              vertical: size.height * 0.022,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${index + 1}  ${entry.characterName}',
                  style: TextStyle(
                    fontSize: size.width * 0.048,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown.shade900,
                  ),
                ),
                SizedBox(height: size.height * 0.012),
                Text(
                  'Score: ${entry.finalScore}    Rating: ${entry.rating}',
                  style: TextStyle(
                    fontSize: size.width * 0.038,
                    color: Colors.brown.shade800,
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                Wrap(
                  spacing: size.width * 0.05,
                  runSpacing: size.height * 0.006,
                  children: [
                    _statChip(size, 'INT', entry.intellect),
                    _statChip(size, 'FIT', entry.fitness),
                    _statChip(size, 'CHR', entry.charisma),
                    _statChip(size, 'CRT', entry.creativity),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(Size size, String label, int value) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.025,
        vertical: size.height * 0.005,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.45),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$label $value',
        style: TextStyle(
          fontSize: size.width * 0.033,
          fontWeight: FontWeight.w700,
          color: Colors.brown.shade900,
        ),
      ),
    );
  }
}
