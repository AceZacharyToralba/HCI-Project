import 'dart:async';

import 'package:flutter/material.dart';

import '../game/audio_manager.dart';
import '../models/character_model.dart';
import 'game_screen.dart';
import 'main_menu.dart';

class CharacterSelection extends StatefulWidget {
  const CharacterSelection({super.key});

  @override
  State<CharacterSelection> createState() => _CharacterSelectionState();
}

class _CharacterSelectionState extends State<CharacterSelection> {
  static const String _mainMenuAssetBase = 'assets/main_menu assets';
  int currentIndex = 0;
  bool isStartingGame = false;
  final AudioManager audioManager = AudioManager.instance;

  final List<CharacterModel> characters = const [
    CharacterModel(
      name: 'Nerd Guy',
      startingIntellect: 15,
      startingFitness: 8,
      startingCharisma: 6,
      startingCreativity: 9,
      intellectGrowthRate: 0.20,
      fitnessGrowthRate: 0.0,
      charismaGrowthRate: 0.0,
      creativityGrowthRate: 0.0,
      restEnergyBonus: 0,
    ),
    CharacterModel(
      name: 'Athletic Guy',
      startingIntellect: 8,
      startingFitness: 15,
      startingCharisma: 9,
      startingCreativity: 6,
      fitnessGrowthRate: 0.20,
      intellectGrowthRate: 0.0,
      charismaGrowthRate: 0.0,
      creativityGrowthRate: 0.0,
      restEnergyBonus: 0,
    ),
    CharacterModel(
      name: 'Lazy Student',
      startingIntellect: 10,
      startingFitness: 10,
      startingCharisma: 10,
      startingCreativity: 10,
      intellectGrowthRate: 0.0,
      fitnessGrowthRate: 0.0,
      charismaGrowthRate: 0.0,
      creativityGrowthRate: 0.0,
      restEnergyBonus: 20,
    ),
    CharacterModel(
      name: 'Creative Girl',
      startingIntellect: 9,
      startingFitness: 7,
      startingCharisma: 12,
      startingCreativity: 12,
      intellectGrowthRate: 0.0,
      fitnessGrowthRate: 0.0,
      charismaGrowthRate: 0.10,
      creativityGrowthRate: 0.10,
      restEnergyBonus: 0,
    ),
  ];

  @override
  void initState() {
    super.initState();

    unawaited(audioManager.init());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_precachePortraitImages());
    });
  }

  Future<void> _precachePortraitImages() async {
    const portraitPaths = <String>[
      'assets/character_portrait/nerd_guy_portrait.png',
      'assets/character_portrait/athletic_guy_portrait.png',
      'assets/character_portrait/lazy_student_portrait.png',
      'assets/character_portrait/creative_girl_portrait.png',
    ];

    final imagesToPrecache = <String>[
      ...portraitPaths,
      '$_mainMenuAssetBase/left_arrow.png',
      '$_mainMenuAssetBase/right_arrow.png',
      '$_mainMenuAssetBase/home_icon sprite.png',
    ];

    for (final imagePath in imagesToPrecache) {
      await precacheImage(AssetImage(imagePath), context);
    }
  }

  String _formatStatWithGrowth({
    required String statName,
    required int statValue,
    required double growthRate,
  }) {
    if (growthRate > 0) {
      return '$statName: $statValue  ${(growthRate * 100).toInt()}%';
    }

    return '$statName: $statValue';
  }

  void previousCharacter() {
    setState(() {
      currentIndex--;
      if (currentIndex < 0) {
        currentIndex = characters.length - 1;
      }
    });
  }

  void nextCharacter() {
    setState(() {
      currentIndex++;
      if (currentIndex >= characters.length) {
        currentIndex = 0;
      }
    });
  }

  Future<void> _goHome() {
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 240),
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: const MainMenu(),
        ),
      ),
      (route) => false,
    );
    return Future<void>.value();
  }

  Route _buildBlackTransitionRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 1400),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final fadeToBlack = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.58, curve: Curves.easeInOutCubic),
        );
        final fadeInChild = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.72, 1.0, curve: Curves.easeOut),
        );

        return AnimatedBuilder(
          animation: animation,
          builder: (_, __) {
            return Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(
                  color: Colors.black.withOpacity(fadeToBlack.value),
                ),
                Opacity(
                  opacity: fadeInChild.value,
                  child: child,
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final currentCharacter = characters[currentIndex];
    final portraitFileName = currentCharacter.name
        .toLowerCase()
        .replaceAll(' ', '_');

    return Scaffold(
      backgroundColor: Colors.yellow.shade700,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.yellow.shade700,
            ),
          ),
          Positioned(
            top: -size.width * 0.15,
            right: -size.width * 0.08,
            child: Container(
              width: size.width * 0.5,
              height: size.width * 0.5,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -size.width * 0.18,
            left: -size.width * 0.1,
            child: Container(
              width: size.width * 0.55,
              height: size.width * 0.55,
              decoration: BoxDecoration(
                color: Colors.orange.shade900.withOpacity(0.14),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                size.width * 0.05,
                size.height * 0.025,
                size.width * 0.05,
                size.height * 0.03,
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _decoratedPanel(
                          height: size.height * 0.12,
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.05,
                            vertical: size.height * 0.018,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Choose Your',
                                style: TextStyle(
                                  fontSize: size.width * 0.04,
                                  color: Colors.brown.shade900,
                                ),
                              ),
                              Text(
                                'Scholar',
                                style: TextStyle(
                                  fontSize: size.width * 0.075,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: size.width * 0.03),
                      _iconButton(
                        size: size,
                        onTap: _goHome,
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.03),
                  Expanded(
                    child: _decoratedPanel(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.04,
                        vertical: size.height * 0.028,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _arrowButton(
                                size: size,
                                onTap: previousCharacter,
                                isLeft: true,
                              ),
                              SizedBox(width: size.width * 0.04),
                              Column(
                                children: [
                                  Container(
                                    width: size.width * 0.44,
                                    height: size.width * 0.44,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.55),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.18),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Image.asset(
                                      'assets/character_portrait/${portraitFileName}_portrait.png',
                                      fit: BoxFit.cover,
                                      filterQuality: FilterQuality.none,
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.018),
                                  Text(
                                    currentCharacter.name,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: size.width * 0.05,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.brown.shade900,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: size.width * 0.04),
                              _arrowButton(
                                size: size,
                                onTap: nextCharacter,
                                isLeft: false,
                              ),
                            ],
                          ),
                          SizedBox(height: size.height * 0.03),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.05,
                              vertical: size.height * 0.022,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _statText(
                                  size,
                                  _formatStatWithGrowth(
                                    statName: 'Intellect',
                                    statValue: currentCharacter.startingIntellect,
                                    growthRate: currentCharacter.intellectGrowthRate,
                                  ),
                                ),
                                _statText(
                                  size,
                                  _formatStatWithGrowth(
                                    statName: 'Fitness',
                                    statValue: currentCharacter.startingFitness,
                                    growthRate: currentCharacter.fitnessGrowthRate,
                                  ),
                                ),
                                _statText(
                                  size,
                                  _formatStatWithGrowth(
                                    statName: 'Charisma',
                                    statValue: currentCharacter.startingCharisma,
                                    growthRate: currentCharacter.charismaGrowthRate,
                                  ),
                                ),
                                _statText(
                                  size,
                                  _formatStatWithGrowth(
                                    statName: 'Creativity',
                                    statValue: currentCharacter.startingCreativity,
                                    growthRate: currentCharacter.creativityGrowthRate,
                                  ),
                                ),
                                if (currentCharacter.restEnergyBonus > 0)
                                  _statText(
                                    size,
                                    'Rest Bonus: +${currentCharacter.restEnergyBonus}',
                                  ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          _texturedButton(
                            width: size.width * 0.52,
                            height: size.height * 0.09,
                            texturePath: 'assets/gameplay screeen/Pause Inner Buttons.png',
                            label: isStartingGame ? 'LOADING...' : 'START RUN',
                            playButtonSound: false,
                            onTap: () async {
                              if (isStartingGame) return;

                              setState(() {
                                isStartingGame = true;
                              });

                              try {
                                await audioManager.playCharacterSelectionStart();
                              } catch (_) {
                                await Future<void>.delayed(
                                  const Duration(milliseconds: 700),
                                );
                              }
                              if (!mounted) return;

                              await Navigator.push(
                                context,
                                _buildBlackTransitionRoute(
                                  GameScreen(
                                    selectedCharacter: currentCharacter,
                                  ),
                                ),
                              );

                              if (!mounted) return;
                              setState(() {
                                isStartingGame = false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _decoratedPanel({
    required Widget child,
    required EdgeInsets padding,
    double? height,
  }) {
    return SizedBox(
      width: double.infinity,
      height: height,
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
            padding: padding,
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _arrowButton({
    required Size size,
    required VoidCallback onTap,
    required bool isLeft,
  }) {
    return GestureDetector(
      onTap: () {
        audioManager.playButtonClick();
        onTap();
      },
      child: SizedBox(
        width: size.width * 0.12,
        height: size.width * 0.12,
        child: Image.asset(
          isLeft
              ? '$_mainMenuAssetBase/left_arrow.png'
              : '$_mainMenuAssetBase/right_arrow.png',
          fit: BoxFit.contain,
          filterQuality: FilterQuality.none,
        ),
      ),
    );
  }

  Widget _iconButton({
    required Size size,
    required Future<void> Function() onTap,
  }) {
    return GestureDetector(
      onTap: () async {
        audioManager.playButtonClick();
        await onTap();
      },
      child: SizedBox(
        width: size.width * 0.13,
        height: size.width * 0.13,
        child: Image.asset(
          '$_mainMenuAssetBase/home_icon sprite.png',
          fit: BoxFit.contain,
          filterQuality: FilterQuality.none,
        ),
      ),
    );
  }

  Widget _texturedButton({
    required double width,
    required double height,
    required String texturePath,
    required String label,
    bool playButtonSound = true,
    required Future<void> Function() onTap,
  }) {
    return GestureDetector(
      onTap: () async {
        if (playButtonSound) {
          audioManager.playButtonClick();
        }
        await onTap();
      },
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Image.asset(
                texturePath,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.none,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                shadows: [
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
    );
  }

  Widget _statText(Size size, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: size.height * 0.004),
      child: Text(
        text,
        style: TextStyle(
          fontSize: size.width * 0.042,
          fontWeight: FontWeight.w600,
          color: Colors.brown.shade900,
        ),
      ),
    );
  }
}
