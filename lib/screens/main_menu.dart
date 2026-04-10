import 'dart:async';

import 'package:flutter/material.dart';
import '../game/audio_manager.dart';
import 'character_selection.dart';
import 'leaderboard_screen.dart';
import 'option_screen.dart';
import 'tutorial_screen.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  // ==========================================================
  // UI STATE
  // ==========================================================

  final AudioManager audioManager = AudioManager.instance;

  @override
  void initState() {
    super.initState();

    unawaited(_prepareAudio());
  }

  Future<void> _prepareAudio() async {
    await audioManager.init();
    if (!mounted) return;
    await audioManager.playMainMenuBgm();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const menuLabels = ['PLAY', 'LEADERBOARD', 'OPTIONS', 'TUTORIAL', 'QUIT'];

    return Scaffold(
      body: Stack(
        children: [
          // ======================================================
          // MAIN MENU BACKGROUND
          // ======================================================
          Positioned.fill(
            child: Container(
              color: Colors.yellow.shade700,
            ),
          ),

          // ======================================================
          // MAIN MENU CONTENT
          // ======================================================
          SafeArea(
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.12),

                  Text(
                    "Stat Scholar",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: size.width * 0.08,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: size.height * 0.08),

                  _menuButton(size, menuLabels[0], () {
                    audioManager.playButtonClick();

                    Navigator.push(context, _buildSlideRoute(const CharacterSelection()));
                  }),

                  _menuButton(size, menuLabels[1], () {
                    audioManager.playButtonClick();

                    Navigator.push(context, _buildRiseRoute(const LeaderboardScreen()));
                  }),

                  _menuButton(size, menuLabels[2], () {
                    audioManager.playButtonClick();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OptionScreen(),
                        ),
                      );
                  }),

                  _menuButton(size, menuLabels[3], () {
                    audioManager.playButtonClick();

                    Navigator.push(context, _buildFadeRoute(const TutorialScreen()));
                  }),

                  _menuButton(size, menuLabels[4], () {
                    audioManager.playButtonClick();

                    Navigator.pop(context);
                  }),

                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // PLACEHOLDER BUTTON
  // Replace later with your real textures
  // ==========================================================
  Widget _menuButton(Size size, String label, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: size.width * 0.6,
          height: size.height * 0.08,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/main_menu_buttons.png',
                  fit: BoxFit.fill,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: size.width * 0.042,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  shadows: const [
                    Shadow(
                      color: Colors.white,
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Route _buildSlideRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (_, animation, __) => page,
      transitionsBuilder: (_, animation, __, child) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0.22, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: offsetAnimation,
            child: child,
          ),
        );
      },
    );
  }

  Route _buildRiseRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 360),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, animation, __) => page,
      transitionsBuilder: (_, animation, __, child) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: offsetAnimation,
            child: child,
          ),
        );
      },
    );
  }

  Route _buildFadeRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (_, animation, __) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
          child: child,
        );
      },
    );
  }
}
