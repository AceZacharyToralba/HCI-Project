import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import '../game/audio_manager.dart';
import '../game/game_manager.dart';
import '../models/game_event.dart';
import '../models/character_model.dart';
import 'result_screen.dart';
import 'main_menu.dart';

class GameScreen extends StatefulWidget {
  final CharacterModel selectedCharacter;

  const GameScreen({
    super.key,
    required this.selectedCharacter,
    });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const String _uiBasePath = 'assets/gameplay screeen';

  // ==========================================
  // Create one GameManager for this game session.
  // ==========================================
  late final GameManager gameManager;
  final AudioManager audioManager = AudioManager.instance;

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
  void initState() {
    super.initState();

    gameManager = GameManager(
      selectedCharacter: widget.selectedCharacter,
    );
    gameManager.setBgmVolume(audioManager.bgmVolume);
    gameManager.setSfxVolume(audioManager.sfxVolume);
    displayBuffedStat = gameManager.buffedStat;
    displayTurnsLeft = gameManager.turnsLeft;
    displaySemesterText = gameManager.currentSemesterText;
    displayEnergy = gameManager.energy;
    displayIntellect = gameManager.intellect;
    displayFitness = gameManager.fitness;
    displayCharisma = gameManager.charisma;
    displayCreativity = gameManager.creativity;

    unawaited(_prepareScreenAudio());
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _precacheGameplayImages();
    });
  }

  Future<void> _prepareScreenAudio() async {
    await audioManager.init();
    if (!mounted) return;
    await audioManager.playSemesterBgm(gameManager.currentWave);
  }

  // ==========================================================
  // PRECACHE GAMEPLAY IMAGES
  // ==========================================================
  Future<void> _precacheGameplayImages() async {
    // ----------------------------------------------------------
    // Background images
    // ----------------------------------------------------------
    final backgroundPaths = [
      'assets/backgrounds/intellect_bg.png',
      'assets/backgrounds/fitness_bg.png',
      'assets/backgrounds/charisma_bg.png',
      'assets/backgrounds/creativity_bg.png',
      'assets/backgrounds/work_bg.png',
      'assets/backgrounds/rest_bg.png',
    ];

    // ----------------------------------------------------------
    // Character pose images for the selected character
    // ----------------------------------------------------------
    final characterFileName = widget.selectedCharacter.name
        .toLowerCase()
        .replaceAll(' ', '_');

    final characterPosePaths = [
      'assets/characters/${characterFileName}_intellect_pose.png',
      'assets/characters/${characterFileName}_fitness_pose.png',
      'assets/characters/${characterFileName}_charisma_pose.png',
      'assets/characters/${characterFileName}_creativity_pose.png',
      'assets/characters/${characterFileName}_work_pose.png',
      'assets/characters/${characterFileName}_rest_pose.png',
    ];

    final uiTexturePaths = [
      '$_uiBasePath/Goal Button.png',
      '$_uiBasePath/Stat Panel.png',
      '$_uiBasePath/Store Panel.png',
      '$_uiBasePath/Event Panel.png',
      '$_uiBasePath/Pause Panel.png',
      '$_uiBasePath/Puase Button.png',
      '$_uiBasePath/Pause Inner Buttons.png',
      '$_uiBasePath/Auto Event OK Button.png',
      '$_uiBasePath/Event panel buttons.png',
      '$_uiBasePath/bottom_buttons/Rest.png',
      '$_uiBasePath/bottom_buttons/Work.png',
      '$_uiBasePath/bottom_buttons/Store.png',
      '$_uiBasePath/stat_buttons/intellect_buttons/Int_Level 1.png',
      '$_uiBasePath/stat_buttons/intellect_buttons/Int_Level 2.png',
      '$_uiBasePath/stat_buttons/intellect_buttons/Int_Level 3.png',
      '$_uiBasePath/stat_buttons/fitness_buttons/Fit_Level 1.png',
      '$_uiBasePath/stat_buttons/fitness_buttons/Fit_Level 2.png',
      '$_uiBasePath/stat_buttons/fitness_buttons/Fit_Level 3.png',
      '$_uiBasePath/stat_buttons/charisma_buttons/Charisma_Level 1.png',
      '$_uiBasePath/stat_buttons/charisma_buttons/Charisma_Level 2.png',
      '$_uiBasePath/stat_buttons/charisma_buttons/Charisma_Level 3.png',
      '$_uiBasePath/stat_buttons/creativity_buttons/Creativity_Level 1.png',
      '$_uiBasePath/stat_buttons/creativity_buttons/Creativity_Level 2.png',
      '$_uiBasePath/stat_buttons/creativity_buttons/Creativity_Level 3.png',
    ];

    // Precache backgrounds
    for (final path in backgroundPaths) {
      await precacheImage(AssetImage(path), context);
    }

    // Precache character poses
    for (final path in characterPosePaths) {
      await precacheImage(AssetImage(path), context);
    }

    // Precache gameplay UI textures so panel/button transitions do not hitch.
    for (final path in uiTexturePaths) {
      await precacheImage(AssetImage(path), context);
    }
  }

  // ==========================================================
  // ACTION FEEDBACK UI STATE
  // ==========================================================
  bool isShowingActionFeedback = false;
  String feedbackText = '';
  Color feedbackColor = Colors.white;
  Alignment feedbackAlignment = const Alignment(-1.2, 0);
  bool isStorePanelVisible = false;
  bool isStorePanelAnimatingIn = false;
  double storePanelHiddenOffsetY = 1.2;
  bool isEventPanelVisible = false;
  bool isEventPanelAnimatingIn = false;
  double eventPanelHiddenOffsetY = 1.2;
  GameEvent? displayedEvent;
  bool isPausePanelVisible = false;
  bool isPausePanelAnimatingIn = false;
  double pausePanelHiddenOffsetY = 1.2;
  bool isPlayingTurnTransition = false;
  bool isTurnTransitionPanelVisible = false;
  double turnTransitionOffsetY = 1.2;
  bool _isLeavingGameScreen = false;
  final Random _floatingGainRandom = Random();
  final List<_FloatingStatGain> _floatingStatGains = [];

  // ==========================================================
  // SHOW FEEDBACK
  // ==========================================================
  Future<void> _showActionFeedback({
    required String text,
    required Color color,
    Future<void> Function()? onCenterHold,
    VoidCallback? onExitStart,
    int slideDurationMs = 220,
    int centerPauseMs = 80,
  }) async {
    if (!mounted || _isLeavingGameScreen) return;

    setState(() {
      isShowingActionFeedback = true;
      feedbackText = text;
      feedbackColor = color;
      feedbackAlignment = const Alignment(-1.2, 0);
    });

    await Future.delayed(const Duration(milliseconds: 16));
    if (!mounted || _isLeavingGameScreen) return;

    setState(() {
      feedbackAlignment = Alignment.center;
    });

    await Future.delayed(Duration(milliseconds: slideDurationMs));
    if (!mounted || _isLeavingGameScreen) return;

    if (onCenterHold != null) {
      await onCenterHold();
      if (!mounted || _isLeavingGameScreen) return;
    }

    if (centerPauseMs > 0) {
      await Future.delayed(Duration(milliseconds: centerPauseMs));
      if (!mounted || _isLeavingGameScreen) return;
    }

    setState(() {
      feedbackAlignment = const Alignment(1.2, 0);
    });
    onExitStart?.call();

    await Future.delayed(Duration(milliseconds: slideDurationMs));

    if (!mounted || _isLeavingGameScreen) return;

    setState(() {
      isShowingActionFeedback = false;
      feedbackAlignment = const Alignment(-1.2, 0);
    });
  }

  // ==========================================================
  // FEEDBACK FOR TRAINING / WORK RESULT
  // ==========================================================
  Future<void> _showExecutionFeedback({
    VoidCallback? onExitStart,
    Map<String, int> floatingStatGains = const {},
  }) async {
    if (gameManager.lastActionSucceeded) {
      audioManager.playTrainingSuccess();
      if (gameManager.lastActionType == 'work') {
        audioManager.playCoinsGained();
      }
    } else {
      audioManager.playTrainingFailed();
    }

    await _showActionFeedback(
      text: gameManager.lastActionSucceeded ? 'SUCCESS!' : 'FAILED!',
      color: gameManager.lastActionSucceeded
          ? Colors.greenAccent
          : Colors.redAccent,
      onCenterHold: () async {
        if (!mounted || _isLeavingGameScreen) return;

        _showFloatingStatGains(floatingStatGains);
        setState(() {
          // Let the energy bar animate while the result text is paused at center.
          displayEnergy = gameManager.energy;
        });
        await Future.delayed(const Duration(milliseconds: 180));
      },
      onExitStart: onExitStart,
    );
  }

  Future<void> _showPendingEventIfNeeded() async {
    if (!mounted || _isLeavingGameScreen) return;

    if (gameManager.hasPendingEvent)
    {
      setState(() {
        gameManager.openPendingEvent();
        displayedEvent = gameManager.currentEvent;
        isEventPanelVisible = true;
        isEventPanelAnimatingIn = false;
        eventPanelHiddenOffsetY = 1.2;
      });
      audioManager.playEventPopup();

      await Future.delayed(const Duration(milliseconds: 16));
      if (!mounted || _isLeavingGameScreen || !isEventPanelVisible) return;

      setState(() {
        isEventPanelAnimatingIn = true;
      });
    }
  }

  Future<void> _openStorePanel() async {
    if (!mounted || _isLeavingGameScreen || isStorePanelVisible) return;
    audioManager.playStoreOpen();

    setState(() {
      gameManager.openStore();
      isStorePanelVisible = true;
      isStorePanelAnimatingIn = false;
      storePanelHiddenOffsetY = 1.2;
    });

    await Future.delayed(const Duration(milliseconds: 16));
    if (!mounted || _isLeavingGameScreen || !isStorePanelVisible) return;

    setState(() {
      isStorePanelAnimatingIn = true;
    });
  }

  Future<void> _closeStorePanel() async {
    if (!mounted || _isLeavingGameScreen || !isStorePanelVisible) return;

    setState(() {
      storePanelHiddenOffsetY = 1.2;
      isStorePanelAnimatingIn = false;
    });

    await Future.delayed(const Duration(milliseconds: 220));
    if (!mounted || _isLeavingGameScreen) return;

    setState(() {
      gameManager.closeStore();
      isStorePanelVisible = false;
    });
  }

  Future<void> _resolveAutoEventWithAnimation() async {
    if (!mounted || _isLeavingGameScreen || !isEventPanelVisible) return;

    final oldIntellect = gameManager.intellect;
    final oldFitness = gameManager.fitness;
    final oldCharisma = gameManager.charisma;
    final oldCreativity = gameManager.creativity;

    setState(() {
      eventPanelHiddenOffsetY = -1.2;
      isEventPanelAnimatingIn = false;
    });

    await Future.delayed(const Duration(milliseconds: 220));
    if (!mounted || _isLeavingGameScreen) return;

    setState(() {
      gameManager.resolveAutoEvent();
      displayedEvent = null;
      isEventPanelVisible = false;
    });

    final eventStatGains = _getPositiveStatChanges(
      oldIntellect: oldIntellect,
      oldFitness: oldFitness,
      oldCharisma: oldCharisma,
      oldCreativity: oldCreativity,
      newIntellect: gameManager.intellect,
      newFitness: gameManager.fitness,
      newCharisma: gameManager.charisma,
      newCreativity: gameManager.creativity,
    );
    _syncDisplayValues();
    _showFloatingStatGains(eventStatGains);
    await _playTurnTransition(settleDelayMs: 220);
    if (!mounted || _isLeavingGameScreen) return;
    _checkGameEnd();
  }

  Future<void> _openPausePanel() async {
    if (!mounted || _isLeavingGameScreen || isPausePanelVisible) return;

    setState(() {
      gameManager.openPauseMenu();
      isPausePanelVisible = true;
      isPausePanelAnimatingIn = false;
      pausePanelHiddenOffsetY = 1.2;
    });

    await Future.delayed(const Duration(milliseconds: 16));
    if (!mounted || _isLeavingGameScreen || !isPausePanelVisible) return;

    setState(() {
      isPausePanelAnimatingIn = true;
    });
  }

  Future<void> _closePausePanel() async {
    if (!mounted || _isLeavingGameScreen || !isPausePanelVisible) return;

    setState(() {
      pausePanelHiddenOffsetY = 1.2;
      isPausePanelAnimatingIn = false;
    });

    await Future.delayed(const Duration(milliseconds: 220));
    if (!mounted || _isLeavingGameScreen) return;

    setState(() {
      gameManager.closePauseMenu();
      isPausePanelVisible = false;
    });
  }

  Future<void> _resolveChoiceEventWithAnimation(int index) async {
    if (!mounted || _isLeavingGameScreen || !isEventPanelVisible) return;

    final oldIntellect = gameManager.intellect;
    final oldFitness = gameManager.fitness;
    final oldCharisma = gameManager.charisma;
    final oldCreativity = gameManager.creativity;

    setState(() {
      eventPanelHiddenOffsetY = -1.2;
      isEventPanelAnimatingIn = false;
    });

    await Future.delayed(const Duration(milliseconds: 220));
    if (!mounted || _isLeavingGameScreen) return;

    setState(() {
      gameManager.chooseEventOption(index);
      displayedEvent = null;
      isEventPanelVisible = false;
    });

    final eventStatGains = _getPositiveStatChanges(
      oldIntellect: oldIntellect,
      oldFitness: oldFitness,
      oldCharisma: oldCharisma,
      oldCreativity: oldCreativity,
      newIntellect: gameManager.intellect,
      newFitness: gameManager.fitness,
      newCharisma: gameManager.charisma,
      newCreativity: gameManager.creativity,
    );
    _syncDisplayValues();
    _showFloatingStatGains(eventStatGains);
    await _playTurnTransition(settleDelayMs: 220);
    if (!mounted || _isLeavingGameScreen) return;
    _checkGameEnd();
  }

  // ==========================================================
  // DISPLAY VALUES for animations
  // ==========================================================
  int displayEnergy = 100;
  String displayBuffedStat = 'intellect';
  int displayTurnsLeft = 0;
  String displaySemesterText = '';

  int displayIntellect = 0;
  int displayFitness = 0;
  int displayCharisma = 0;
  int displayCreativity = 0;

  String _formatStatDisplay(int value) {
    if (value >= GameManager.statCap) {
      return 'MAX';
    }
    return '$value / ${GameManager.statCap}';
  }

  Widget _goalProgressRow({
    required Size size,
    required String label,
    required int currentValue,
    required int goalValue,
    required bool isMet,
  }) {
    return Text(
      '$label: $currentValue / $goalValue',
      style: TextStyle(
        fontSize: size.width * 0.038,
        color: isMet ? Colors.green.shade800 : Colors.black,
        fontWeight: isMet ? FontWeight.bold : FontWeight.w500,
      ),
    );
  }

  String _getDisplayedPreviewTextForStat(String statName) {
    if (gameManager.selectedAction == statName && gameManager.isTrainingPreview) {
      final previewGain = gameManager.getTrainingGain(
        statName,
        isBuffed: displayBuffedStat == statName,
      );
      return '+$previewGain';
    }
    return '';
  }

  Map<String, int> _getPositiveStatChanges({
    required int oldIntellect,
    required int oldFitness,
    required int oldCharisma,
    required int oldCreativity,
    required int newIntellect,
    required int newFitness,
    required int newCharisma,
    required int newCreativity,
  }) {
    final gains = <String, int>{};

    final intellectGain = newIntellect - oldIntellect;
    final fitnessGain = newFitness - oldFitness;
    final charismaGain = newCharisma - oldCharisma;
    final creativityGain = newCreativity - oldCreativity;

    if (intellectGain > 0) gains['intellect'] = intellectGain;
    if (fitnessGain > 0) gains['fitness'] = fitnessGain;
    if (charismaGain > 0) gains['charisma'] = charismaGain;
    if (creativityGain > 0) gains['creativity'] = creativityGain;

    return gains;
  }

  Color _floatingGainColor(String statName) {
    switch (statName) {
      case 'intellect':
        return const Color(0xFF5AB8FF);
      case 'fitness':
        return const Color(0xFFECECEC);
      case 'charisma':
        return const Color(0xFFFF7B7B);
      case 'creativity':
        return const Color(0xFF6CFF86);
      default:
        return Colors.white;
    }
  }

  String _trainingButtonTexturePath(String actionName) {
    final level = gameManager.facilityLevel.clamp(1, 3);

    switch (actionName) {
      case 'intellect':
        return '$_uiBasePath/stat_buttons/intellect_buttons/Int_Level $level.png';
      case 'fitness':
        return '$_uiBasePath/stat_buttons/fitness_buttons/Fit_Level $level.png';
      case 'charisma':
        return '$_uiBasePath/stat_buttons/charisma_buttons/Charisma_Level $level.png';
      case 'creativity':
        return '$_uiBasePath/stat_buttons/creativity_buttons/Creativity_Level $level.png';
      default:
        return '';
    }
  }

  String _bottomButtonTexturePath(String label) {
    switch (label) {
      case 'REST':
        return '$_uiBasePath/bottom_buttons/Rest.png';
      case 'WORK':
        return '$_uiBasePath/bottom_buttons/Work.png';
      case 'STORE':
        return '$_uiBasePath/bottom_buttons/Store.png';
      default:
        return '';
    }
  }

  Widget _buildTextureBackground({
    required String assetPath,
    required Widget fallback,
    BoxFit fit = BoxFit.fill,
  }) {
    return _buildGameplayImage(
      assetPath: assetPath,
      fit: fit,
      fallback: fallback,
    );
  }

  Widget _buildGameplayImage({
    required String assetPath,
    required BoxFit fit,
    required Widget fallback,
  }) {
    return Image.asset(
      assetPath,
      fit: fit,
      filterQuality: FilterQuality.none,
      isAntiAlias: false,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => fallback,
    );
  }

  Widget _buildPanelSurface({
    required String assetPath,
    required Widget child,
    required Widget fallback,
  }) {
    return Stack(
      children: [
        Positioned.fill(
          child: _buildTextureBackground(
            assetPath: assetPath,
            fit: BoxFit.fill,
            fallback: fallback,
          ),
        ),
        child,
      ],
    );
  }

  Widget _buildGameplayTextButton({
    required Size size,
    required String label,
    required VoidCallback onTap,
    required String assetPath,
    required Widget fallback,
    double? width,
  }) {
    final button = SizedBox(
      width: width,
      child: _PressableScale(
        onTap: onTap,
        child: SizedBox(
          height: size.height * 0.06,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: _buildTextureBackground(
                  assetPath: assetPath,
                  fit: BoxFit.fill,
                  fallback: fallback,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: size.width * 0.038,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return width == null ? button : Align(alignment: Alignment.center, child: button);
  }

  TextStyle _buttonOverlayTextStyle(Size size, {
    required double fontSize,
    Color color = Colors.black,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: color,
      shadows: const [
        Shadow(
          color: Colors.white,
          blurRadius: 6,
        ),
        Shadow(
          color: Colors.black54,
          blurRadius: 4,
          offset: Offset(1, 1),
        ),
      ],
    );
  }

  Color _failureRateColor(int failureRateValue) {
    if (failureRateValue <= 15) {
      return Colors.green.shade700;
    }
    if (failureRateValue <= 55) {
      return Colors.orange.shade800;
    }
    return Colors.red.shade700;
  }

  List<BoxShadow> _selectedButtonShadows() {
    return const [
      BoxShadow(
        color: Color.fromARGB(220, 255, 255, 255),
        blurRadius: 4,
        spreadRadius: 1,
      ),
      BoxShadow(
        color: Color.fromARGB(220, 0, 0, 0),
        blurRadius: 10,
        spreadRadius: 2,
      ),
    ];
  }

  Widget _outlinedTopText({
    required String text,
    required TextStyle style,
    double strokeWidth = 3,
    TextAlign textAlign = TextAlign.center,
  }) {
    return Stack(
      children: [
        Text(
          text,
          textAlign: textAlign,
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = Colors.black,
          ),
        ),
        Text(
          text,
          textAlign: textAlign,
          style: style.copyWith(
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _outlinedText({
    required String text,
    required TextStyle style,
    required Color fillColor,
    Color strokeColor = Colors.black,
    double strokeWidth = 2,
    TextAlign textAlign = TextAlign.center,
  }) {
    return Stack(
      children: [
        Text(
          text,
          textAlign: textAlign,
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = strokeColor,
          ),
        ),
        Text(
          text,
          textAlign: textAlign,
          style: style.copyWith(color: fillColor),
        ),
      ],
    );
  }

  Future<void> _showFloatingStatGains(Map<String, int> statGains) async {
    if (!mounted || _isLeavingGameScreen || statGains.isEmpty) return;
    audioManager.playStatsGained();

    final gainEntries = <_FloatingStatGain>[];
    var index = 0;

    for (final entry in statGains.entries) {
      // Keep the popups inside the center area, with small random variation.
      final startX = (_floatingGainRandom.nextDouble() * 0.36) - 0.18;
      final startY = 0.02 + (_floatingGainRandom.nextDouble() * 0.12);
      final endY = startY - 0.14 - (_floatingGainRandom.nextDouble() * 0.05);

      gainEntries.add(
        _FloatingStatGain(
          id: DateTime.now().microsecondsSinceEpoch + index,
          text: '+${entry.value}',
          color: _floatingGainColor(entry.key),
          alignment: Alignment(startX, startY),
          floatAlignment: Alignment(startX, endY),
          opacity: 0,
          scale: 0.7,
        ),
      );
      index++;
    }

    setState(() {
      _floatingStatGains.addAll(gainEntries);
    });

    await Future.delayed(const Duration(milliseconds: 16));
    if (!mounted || _isLeavingGameScreen) return;

    setState(() {
      for (final gainEntry in gainEntries) {
        gainEntry.opacity = 1;
        gainEntry.scale = 1;
        gainEntry.alignment = gainEntry.floatAlignment;
      }
    });

    await Future.delayed(const Duration(milliseconds: 260));
    if (!mounted || _isLeavingGameScreen) return;

    setState(() {
      for (final gainEntry in gainEntries) {
        gainEntry.opacity = 0;
      }
    });

    await Future.delayed(const Duration(milliseconds: 220));
    if (!mounted || _isLeavingGameScreen) return;

    setState(() {
      _floatingStatGains.removeWhere(
        (existingGain) => gainEntries.any((newGain) => newGain.id == existingGain.id),
      );
    });
  }

  void _syncDisplayValues() {
    if (!mounted || _isLeavingGameScreen) return;

    setState(() {
      // Keep the animated display values aligned with the real game state.
      displayEnergy = gameManager.energy;
      displayIntellect = gameManager.intellect;
      displayFitness = gameManager.fitness;
      displayCharisma = gameManager.charisma;
      displayCreativity = gameManager.creativity;
    });
  }

  Future<void> _playTurnTransition({int settleDelayMs = 0}) async {
    if (!mounted || _isLeavingGameScreen || isPlayingTurnTransition) return;
    audioManager.playTurnTransition();

    setState(() {
      isPlayingTurnTransition = true;
    });

    if (settleDelayMs > 0) {
      await Future.delayed(Duration(milliseconds: settleDelayMs));
      if (!mounted || _isLeavingGameScreen) return;
    }

    setState(() {
      isTurnTransitionPanelVisible = true;
      turnTransitionOffsetY = 1.2;
    });

    await Future.delayed(const Duration(milliseconds: 16));
    if (!mounted || _isLeavingGameScreen) return;

    setState(() {
      turnTransitionOffsetY = 0;
    });

    await Future.delayed(const Duration(milliseconds: 320));
    if (!mounted || _isLeavingGameScreen) return;

    await Future.delayed(const Duration(milliseconds: 320));
    if (!mounted || _isLeavingGameScreen) return;

    setState(() {
      turnTransitionOffsetY = -1.2;
    });

    await Future.delayed(const Duration(milliseconds: 320));
    if (!mounted || _isLeavingGameScreen) return;

    setState(() {
      displayBuffedStat = gameManager.buffedStat;
      displayTurnsLeft = gameManager.turnsLeft;
      displaySemesterText = gameManager.currentSemesterText;
      isPlayingTurnTransition = false;
      isTurnTransitionPanelVisible = false;
      turnTransitionOffsetY = 1.2;
    });
    await audioManager.playSemesterBgm(gameManager.currentWave);
  }

  Future<void> _runActionSequence({bool showExecutionFeedback = true}) async {
    final trainingStatGains = _getPositiveStatChanges(
      oldIntellect: displayIntellect,
      oldFitness: displayFitness,
      oldCharisma: displayCharisma,
      oldCreativity: displayCreativity,
      newIntellect: gameManager.intellect,
      newFitness: gameManager.fitness,
      newCharisma: gameManager.charisma,
      newCreativity: gameManager.creativity,
    );
    Future<void>? transitionFuture;

    if (showExecutionFeedback) {
      // 1. SUCCESS / FAILED
      await _showExecutionFeedback(
        floatingStatGains: trainingStatGains,
        onExitStart: () {
          transitionFuture ??= _playTurnTransition();
        },
      );
    } else {
      await _showActionFeedback(
        text: 'RESTED!',
        color: Colors.cyanAccent,
        onCenterHold: () async {
          if (!mounted || _isLeavingGameScreen) return;

          setState(() {
            // Rest updates the energy bar during the same center pause.
            displayEnergy = gameManager.energy;
          });
          await Future.delayed(const Duration(milliseconds: 180));
        },
        onExitStart: () {
          transitionFuture ??= _playTurnTransition();
        },
      );
    }

    if (!mounted || _isLeavingGameScreen) return;

    // STAT UPDATE
    setState(() {
      displayIntellect = gameManager.intellect;
      displayFitness = gameManager.fitness;
      displayCharisma = gameManager.charisma;
      displayCreativity = gameManager.creativity;
    });

    await (transitionFuture ?? _playTurnTransition());
    if (!mounted || _isLeavingGameScreen) return;

    // Events (if any)
    await _showPendingEventIfNeeded();
    if (!mounted || _isLeavingGameScreen) return;

    // CHECK END
    _checkGameEnd();
  }

  // ==========================================================
  // CHECK GAME RESULT
  // If the game is won or lost, go to the result screen.
  // ==========================================================
  void _checkGameEnd() {
    if (!mounted || _isLeavingGameScreen) return;

    if (gameManager.gameWon || gameManager.gameLost) {
      _isLeavingGameScreen = true;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(gameManager: gameManager),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Real current energy
    final currentEnergy = displayEnergy;

    // Actions that should preview energy change
    final isEnergyPreviewAction =
        gameManager.selectedAction == 'intellect' ||
        gameManager.selectedAction == 'fitness' ||
        gameManager.selectedAction == 'charisma' ||
        gameManager.selectedAction == 'creativity' ||
        gameManager.selectedAction == 'work' ||
        gameManager.selectedAction == 'rest';

    // Preview energy result
    final previewEnergy = isEnergyPreviewAction
        ? gameManager.getPreviewEnergyValue()
        : displayEnergy;

    final isShowingEnergyPreview = isEnergyPreviewAction;
    return Scaffold(
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          children: [
            // ==========================================
            // BACKGROUND 
            // ==========================================
            Positioned.fill(
              child: RepaintBoundary(
                child: _buildGameplayImage(
                  assetPath: gameManager.getCurrentBackground(),
                  fit: BoxFit.cover,
                  fallback: Container(color: Colors.black),
                ),
              ),
            ),

            // ==========================================
            // TURN COUNTER
            // ==========================================
            Positioned(
              left: size.width * 0.05,
              top: size.height * 0.06,
              child: SizedBox(
                width: size.width * 0.18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _outlinedTopText(
                      text: '$displayTurnsLeft',
                      style: TextStyle(
                        fontSize: size.width * 0.10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _outlinedTopText(
                      text: 'turn(s) left',
                      style: TextStyle(
                        fontSize: size.width * 0.035,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // =========================================================
            // ENERGY / FAILURE RATE SECTION
            // =========================================================
            Positioned(
              left: size.width * 0.24,
              top: size.height * 0.07,
              child: SizedBox(
                width: size.width * 0.68,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Energy: $displayEnergy, Failure rate: ',
                          style: TextStyle(
                            fontSize: size.width * 0.028,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        _outlinedText(
                          text: '${gameManager.displayedFailureRate}%',
                          fillColor: _failureRateColor(
                            gameManager.displayedFailureRate,
                          ),
                          strokeWidth: 2.2,
                          style: TextStyle(
                            fontSize: size.width * 0.042,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.008),

                    // =====================================================
                    // ENERGY BAR
                    // IMPORTANT: keep this INSIDE the Column
                    // =====================================================
                    _buildEnergyBar(
                      size: size,
                      currentEnergy: currentEnergy,
                      previewEnergy: previewEnergy,
                      showPreview: isShowingEnergyPreview,
                    ),
                  ],
                ),
              ),
            ),
            // =========================================================
            // SEMESTER TEXT 
            // =========================================================
            Positioned(
              top: size.height * 0.15,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // SEMESTER TEXT
                  _outlinedTopText(
                    text: displaySemesterText,
                    style: TextStyle(
                      fontSize: size.width * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(width: size.width * 0.03),

                  // GOAL BUTTON
                  _PressableScale(
                    onTap: () {
                      setState(() {
                        gameManager.openGoalPanel();
                      });
                    },
                    child: SizedBox(
                      width: size.width * 0.14,
                      height: size.height * 0.04,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned.fill(
                            child: _buildTextureBackground(
                              assetPath: '$_uiBasePath/Goal Button.png',
                              fallback: Container(color: Colors.orange.shade200),
                            ),
                          ),
                          Text(
                            'GOAL',
                            style: _buttonOverlayTextStyle(
                              size,
                              fontSize: size.width * 0.028,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // =========================================================
            // CHARACTER SPRITE
            // =========================================================
            Positioned(
              left: 0,
              right: 0,
              top: size.height * 0.22, // adjust this if needed
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: Center(
                    child: SizedBox(
                      width: size.width * 0.75,
                      height: size.height * 0.45,
                      child: _buildGameplayImage(
                        assetPath: gameManager.getCurrentCharacterPose(),
                        fit: BoxFit.contain,
                        fallback: const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // =========================================================
            // PREVIEW GAIN ROW
            // This sits ABOVE the stat panel and can overlap the
            // lower part of the character area.
            // =========================================================
            Positioned(
              left: size.width * 0.02,
              top: size.height * 0.56,
              child: SizedBox(
                width: size.width * 0.96,
                child: Row(
                  children: [
                    _previewStatLabel(
                      size,
                      _getDisplayedPreviewTextForStat('intellect'),
                      Colors.blue,
                    ),
                    _previewStatLabel(
                      size,
                      _getDisplayedPreviewTextForStat('fitness'),
                      Colors.grey.shade700,
                    ),
                    _previewStatLabel(
                      size,
                      _getDisplayedPreviewTextForStat('charisma'),
                      Colors.red,
                    ),
                    _previewStatLabel(
                      size,
                      _getDisplayedPreviewTextForStat('creativity'),
                      Colors.green,
                    ),
                  ],
                ),
              ),
            ),

            // ==========================================
            // STATS PANEL
            // ==========================================
            Positioned(
              left: size.width * 0.02,
              top: size.height * 0.60,
              child: RepaintBoundary(
                child: SizedBox(
                  width: size.width * 0.96,
                  height: size.height * 0.10,
                  child: _buildPanelSurface(
                    assetPath: '$_uiBasePath/Stat Panel.png',
                    fallback: Container(color: Colors.white),
                    child: Row(
                      children: [
                        _statCell(
                          size,
                          title: 'Intellect',
                          value: _formatStatDisplay(displayIntellect),
                          titleColor: const Color.fromARGB(255, 16, 79, 131),
                        ),
                        _statCell(
                          size,
                          title: 'Fitness',
                          value: _formatStatDisplay(displayFitness),
                          titleColor: Colors.black54,
                        ),
                        _statCell(
                          size,
                          title: 'Charisma',
                          value: _formatStatDisplay(displayCharisma),
                          titleColor: const Color.fromARGB(255, 161, 49, 41),
                        ),
                        _statCell(
                          size,
                          title: 'Creativity',
                          value: _formatStatDisplay(displayCreativity),
                          titleColor: const Color.fromARGB(255, 48, 105, 50),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ==========================================
            // TRAINING BUTTONS
            // ==========================================
            Positioned(
              left: size.width * 0.03,
              top: size.height * 0.73,
              child: RepaintBoundary(
                child: SizedBox(
                  width: size.width * 0.94,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _circleButton(
                        size,
                        label: 'INT',
                        actionName: 'intellect',
                        onTap: () async {
                          if (isShowingActionFeedback || gameManager.isEventOpen || gameManager.isPauseMenuOpen) return;

                          bool wasExecuting = gameManager.selectedAction == 'intellect';

                          setState(() {
                            gameManager.tapAction('intellect');
                          });

                          if (wasExecuting) {
                            await _runActionSequence();
                          }
                        },
                      ),
                      _circleButton(
                        size,
                        label: 'FIT',
                        actionName: 'fitness',
                        onTap: () async {
                          if (isShowingActionFeedback || gameManager.isEventOpen || gameManager.isPauseMenuOpen) return;

                          bool wasExecuting = gameManager.selectedAction == 'fitness';

                          setState(() {
                            gameManager.tapAction('fitness');
                          });

                          if (wasExecuting) {
                            await _runActionSequence();
                          }
                        },
                      ),
                      _circleButton(
                        size,
                        label: 'CHR',
                        actionName: 'charisma',
                        onTap: () async {
                          if (isShowingActionFeedback || gameManager.isEventOpen || gameManager.isPauseMenuOpen) return;

                          bool wasExecuting = gameManager.selectedAction == 'charisma';

                          setState(() {
                            gameManager.tapAction('charisma');
                          });

                          if (wasExecuting) {
                            await _runActionSequence();
                          }
                        },
                      ),
                      _circleButton(
                        size,
                        label: 'CRT',
                        actionName: 'creativity',
                        onTap: () async {
                          if (isShowingActionFeedback || gameManager.isEventOpen || gameManager.isPauseMenuOpen) return;

                          bool wasExecuting = gameManager.selectedAction == 'creativity';

                          setState(() {
                            gameManager.tapAction('creativity');
                          });

                          if (wasExecuting) {
                            await _runActionSequence();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ==========================================
            // BOTTOM ACTION BUTTONS
            // REST / WORK / STORE
            // ==========================================
            Positioned(
              top: size.height * 0.84,
              left: 0,
              right: 0,
              child: RepaintBoundary(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _bottomButton(
                      size,
                      label: 'REST',
                      onTap: () async {
                        if (isShowingActionFeedback ||
                            gameManager.isEventOpen ||
                            gameManager.isPauseMenuOpen) {
                          return;
                        }
                        bool wasExecuting = gameManager.selectedAction == 'rest';
                        setState(() {
                          gameManager.tapAction('rest');
                        });

                        if (wasExecuting) {
                          await _runActionSequence(showExecutionFeedback: false);
                        }
                      },
                    ),

                    SizedBox(width: size.width * 0.03),
                    Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      _bottomButton(
                        size,
                        label: 'WORK',
                        onTap: () async {
                          if (isShowingActionFeedback || gameManager.isEventOpen || gameManager.isPauseMenuOpen) return;

                          bool wasExecuting = gameManager.selectedAction == 'work';

                          setState(() {
                            gameManager.tapAction('work');
                          });

                          if (wasExecuting) {
                            await _runActionSequence();
                          }
                        },
                      ),

                      if (gameManager.selectedAction == 'work')
                        Positioned(
                          top: -size.height * 0.04,
                          child: Text(
                            '+${gameManager.getPreviewCoinsGain()}',
                            style: TextStyle(
                              fontSize: size.width * 0.04,
                              fontWeight: FontWeight.bold,
                              color: Colors.yellow,
                            ),
                          ),
                        ),
                    ],
                  ),
                    SizedBox(width: size.width * 0.03),
                    _bottomButton(
                      size,
                      label: 'STORE',
                      onTap: () async {
                        await _openStorePanel();
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ==========================================
            // PAUSE BUTTON
            Positioned(
              right: size.width * 0.03,
              bottom: size.height * 0.02,
              child: _PressableScale(
                pressedScale: 0.84,
                onTap: () async {
                  await _openPausePanel();
                },
                child: SizedBox(
                  width: size.width * 0.10,
                  height: size.width * 0.10,
                  child: _buildTextureBackground(
                    assetPath: '$_uiBasePath/Puase Button.png',
                    fallback: Container(color: Colors.orange),
                  ),
                ),
              ),
            ),

            // =========================================================
            // ACTION FEEDBACK TEXT
            // =========================================================
            if (isShowingActionFeedback)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOutCubic,
                    alignment: feedbackAlignment,
                    child: _outlinedText(
                      text: feedbackText,
                      fillColor: feedbackColor,
                      strokeWidth: 3,
                      style: TextStyle(
                        fontSize: size.width * 0.09,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

            // =========================================================
            // FLOATING STAT GAIN TEXT
            // These pop over the middle gameplay area without moving layout.
            // =========================================================
            if (_floatingStatGains.isNotEmpty)
              Positioned.fill(
                child: IgnorePointer(
                  child: Stack(
                    children: _floatingStatGains.map((gainEntry) {
                      return AnimatedAlign(
                        key: ValueKey(gainEntry.id),
                        duration: const Duration(milliseconds: 480),
                        curve: Curves.easeOutCubic,
                        alignment: gainEntry.alignment,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOut,
                          opacity: gainEntry.opacity,
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutBack,
                            scale: gainEntry.scale,
                            child: _outlinedText(
                              text: gainEntry.text,
                              fillColor: gainEntry.color,
                              strokeWidth: 2.5,
                              style: TextStyle(
                                fontSize: size.width * 0.06,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

            // =========================================================
            // GOAL PANEL
            // =========================================================
            if (gameManager.isGoalPanelOpen)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: SizedBox(
                      width: size.width * 0.8,
                      child: _buildPanelSurface(
                        assetPath: '$_uiBasePath/Event Panel.png',
                        fallback: Container(color: Colors.white),
                        child: Padding(
                          padding: EdgeInsets.all(size.width * 0.05),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Semester Goals',
                                style: TextStyle(
                                  fontSize: size.width * 0.05,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: size.height * 0.02),
                              Text(
                                gameManager.currentSemesterText,
                                style: TextStyle(
                                  fontSize: size.width * 0.04,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: size.height * 0.02),
                              Text(
                                'Reach all four goals before turns run out to advance.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: size.width * 0.032,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: size.height * 0.02),
                              _goalProgressRow(
                                size: size,
                                label: 'Intellect',
                                currentValue: gameManager.intellect,
                                goalValue: gameManager.intellectGoal,
                                isMet: gameManager.hasMetGoalForStat('intellect'),
                              ),
                              SizedBox(height: size.height * 0.01),
                              _goalProgressRow(
                                size: size,
                                label: 'Fitness',
                                currentValue: gameManager.fitness,
                                goalValue: gameManager.fitnessGoal,
                                isMet: gameManager.hasMetGoalForStat('fitness'),
                              ),
                              SizedBox(height: size.height * 0.01),
                              _goalProgressRow(
                                size: size,
                                label: 'Charisma',
                                currentValue: gameManager.charisma,
                                goalValue: gameManager.charismaGoal,
                                isMet: gameManager.hasMetGoalForStat('charisma'),
                              ),
                              SizedBox(height: size.height * 0.01),
                              _goalProgressRow(
                                size: size,
                                label: 'Creativity',
                                currentValue: gameManager.creativity,
                                goalValue: gameManager.creativityGoal,
                                isMet: gameManager.hasMetGoalForStat('creativity'),
                              ),
                              SizedBox(height: size.height * 0.02),
                              Text(
                                gameManager.hasMetCurrentGoals
                                    ? 'Ready to proceed to the next semester.'
                                    : 'Any stat still below its goal will cause a failed run at semester end.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: size.width * 0.03,
                                  fontWeight: FontWeight.w600,
                                  color: gameManager.hasMetCurrentGoals
                                      ? Colors.green.shade800
                                      : Colors.red.shade700,
                                ),
                              ),
                              SizedBox(height: size.height * 0.03),
                              _buildGameplayTextButton(
                                size: size,
                                label: 'Close',
                                assetPath: '$_uiBasePath/Auto Event OK Button.png',
                                fallback: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.black26),
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    gameManager.closeGoalPanel();
                                  });
                                },
                                width: size.width * 0.46,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // =========================================================
            // STORE PANEL
            // =========================================================
            if (isStorePanelVisible)
              Positioned.fill(
                child: Container(
                  color: Colors.black54, // dim background
                  child: Center(
                    child: AnimatedSlide(
                      duration: const Duration(milliseconds: 160),
                      curve: Curves.easeInOutCubic,
                      offset: isStorePanelAnimatingIn
                          ? Offset.zero
                          : Offset(0, storePanelHiddenOffsetY),
                      child: SizedBox(
                        width: size.width * 0.9,
                        height: size.height * 0.7,
                        child: _buildPanelSurface(
                          assetPath: '$_uiBasePath/Store Panel.png',
                          fallback: Container(color: Colors.white),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                Text(
                                  'STORE',
                                  style: TextStyle(
                                    fontSize: size.width * 0.06,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Coins: ${gameManager.coins}',
                                  style: TextStyle(
                                    fontSize: size.width * 0.04,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Expanded(
                                  child: GridView.builder(
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      childAspectRatio: 1,
                                    ),
                                    itemCount: gameManager.storeItems.length,
                                    itemBuilder: (context, index) {
                                      final item = gameManager.storeItems[index];

                                      return _PressableScale(
                                        onTap: () {
                                          final coinsBefore = gameManager.coins;
                                          final wasBought = item.isBought;
                                          setState(() {
                                            gameManager.buyItem(index);
                                            // Store purchases should update the visible
                                            // stats and energy immediately, not next turn.
                                            displayEnergy = gameManager.energy;
                                            displayIntellect = gameManager.intellect;
                                            displayFitness = gameManager.fitness;
                                            displayCharisma = gameManager.charisma;
                                            displayCreativity = gameManager.creativity;
                                          });
                                          if (!wasBought && gameManager.coins < coinsBefore) {
                                            audioManager.playCoinsGained();
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: item.isBought
                                                ? Colors.grey
                                                : (gameManager.coins < item.cost
                                                    ? Colors.red.shade100
                                                    : Colors.green.shade100),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.black26,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                item.name,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: size.width * 0.032,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              SizedBox(height: size.height * 0.01),
                                              Text(
                                                '${item.cost} coins',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: size.width * 0.028,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              if (item.isBought) ...[
                                                SizedBox(height: size.height * 0.008),
                                                Text(
                                                  'BOUGHT',
                                                  style: TextStyle(
                                                    fontSize: size.width * 0.028,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                _buildGameplayTextButton(
                                  size: size,
                                  label: 'Close',
                                  assetPath: '$_uiBasePath/Pause Inner Buttons.png',
                                  fallback: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.black26),
                                    ),
                                  ),
                                  onTap: () async {
                                    await _closeStorePanel();
                                  },
                                  width: size.width * 0.46,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            // =========================================================
            // EVENT PANEL
            // Shows either an auto event or a choice event.
            // =========================================================
            if (isEventPanelVisible && displayedEvent != null)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: AnimatedSlide(
                      duration: const Duration(milliseconds: 160),
                      curve: Curves.easeInOutCubic,
                      offset: isEventPanelAnimatingIn
                          ? Offset.zero
                          : Offset(0, eventPanelHiddenOffsetY),
                      child: SizedBox(
                        width: size.width * 0.85,
                        child: _buildPanelSurface(
                          assetPath: '$_uiBasePath/Event Panel.png',
                          fallback: Container(color: Colors.white),
                          child: Padding(
                            padding: EdgeInsets.all(size.width * 0.05),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  displayedEvent!.title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: size.width * 0.055,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: size.height * 0.015),
                                Text(
                                  displayedEvent!.description,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: size.width * 0.038,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: size.height * 0.03),
                                if (displayedEvent!.type == EventType.auto)
                                  _buildGameplayTextButton(
                                    size: size,
                                    label: 'OK',
                                    assetPath: '$_uiBasePath/Auto Event OK Button.png',
                                    fallback: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.black26),
                                      ),
                                    ),
                                    onTap: () async {
                                      if (isShowingActionFeedback) return;
                                      await _resolveAutoEventWithAnimation();
                                    },
                                    width: size.width * 0.28,
                                  ),
                                if (displayedEvent!.type == EventType.choice)
                                  ...List.generate(
                                    displayedEvent!.options.length,
                                    (index) {
                                      final option = displayedEvent!.options[index];

                                      return Padding(
                                        padding: EdgeInsets.only(bottom: size.height * 0.01),
                                        child: _buildGameplayTextButton(
                                          size: size,
                                          label: option.label,
                                          assetPath: '$_uiBasePath/Event panel buttons.png',
                                          fallback: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(color: Colors.black26),
                                            ),
                                          ),
                                          onTap: () async {
                                            if (isShowingActionFeedback) return;
                                            await _resolveChoiceEventWithAnimation(index);
                                          },
                                          width: double.infinity,
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            
            // =========================================================
            // PAUSE MENU PANEL
            // =========================================================
            if (isPausePanelVisible)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: AnimatedSlide(
                      duration: const Duration(milliseconds: 160),
                      curve: Curves.easeInOutCubic,
                      offset: isPausePanelAnimatingIn
                          ? Offset.zero
                          : Offset(0, pausePanelHiddenOffsetY),
                      child: SizedBox(
                        width: size.width * 0.82,
                        child: _buildPanelSurface(
                          assetPath: '$_uiBasePath/Pause Panel.png',
                          fallback: Container(color: Colors.white),
                          child: Padding(
                            padding: EdgeInsets.all(size.width * 0.05),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'PAUSED',
                                  style: TextStyle(
                                    fontSize: size.width * 0.06,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: size.height * 0.025),
                                Text(
                                  'BGM Volume',
                                  style: TextStyle(
                                    fontSize: size.width * 0.04,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Slider(
                                  value: gameManager.bgmVolume,
                                  min: 0.0,
                                  max: 1.0,
                                  onChanged: (value) {
                                    audioManager.setBgmVolume(value);
                                    setState(() {
                                      gameManager.setBgmVolume(value);
                                    });
                                  },
                                ),
                                SizedBox(height: size.height * 0.01),
                                Text(
                                  'SFX Volume',
                                  style: TextStyle(
                                    fontSize: size.width * 0.04,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Slider(
                                  value: gameManager.sfxVolume,
                                  min: 0.0,
                                  max: 1.0,
                                  onChanged: (value) {
                                    audioManager.setSfxVolume(value);
                                    setState(() {
                                      gameManager.setSfxVolume(value);
                                    });
                                  },
                                ),
                                SizedBox(height: size.height * 0.025),
                                _buildGameplayTextButton(
                                  size: size,
                                  label: 'Resume',
                                  assetPath: '$_uiBasePath/Pause Inner Buttons.png',
                                  fallback: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.black26),
                                    ),
                                  ),
                                  onTap: () async {
                                    await _closePausePanel();
                                  },
                                  width: double.infinity,
                                ),
                                SizedBox(height: size.height * 0.012),
                                _buildGameplayTextButton(
                                  size: size,
                                  label: 'Quit',
                                  assetPath: '$_uiBasePath/Pause Inner Buttons.png',
                                  fallback: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.black26),
                                    ),
                                  ),
                                  onTap: () async {
                                    await _closePausePanel();
                                    if (!mounted) return;
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      _buildBlackTransitionRoute(
                                        const MainMenu(),
                                      ),
                                      (route) => false,
                                    );
                                  },
                                  width: double.infinity,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // =========================================================
            // TURN TRANSITION PANEL
            // =========================================================
            if (isPlayingTurnTransition)
              Positioned.fill(
                child: AbsorbPointer(
                  absorbing: true,
                  child: ClipRect(
                    child: AnimatedSlide(
                        duration: const Duration(milliseconds: 320),
                      curve: Curves.easeInOutCubic,
                        offset: Offset(0, turnTransitionOffsetY),
                      child: Container(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ==============================================
  // Reusable stat cell widget
  // ===============================================================
  Widget _statCell(
  Size size, {
  required String title,
  required String value,
  required Color titleColor,
  }) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.004,
          vertical: size.height * 0.004,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: size.width * 0.040,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            SizedBox(height: size.height * 0.003),
            Text(
              value,
              style: TextStyle(
                fontSize: size.width * 0.032,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================
  // Reusable circle training button
  // ==============================================
  Widget _circleButton(
    Size size, {
    required String label,
    required String actionName,
    required Future<void> Function() onTap,
  }) {
    bool isSelected = gameManager.selectedAction == actionName;
    bool isBuffed = displayBuffedStat == actionName;
    
    return _PressableScale(
      pressedScale: 0.9,
      onTap: () async {
        await onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()
          ..translate(0.0, isSelected ? -10.0 : 0.0)
          ..scale(isSelected ? 1.05 : 1.0),
        child: SizedBox(
          width: size.width * 0.205,
          height: size.width * 0.205,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(
                      color: Colors.white,
                      width: 3,
                    )
                  : null,
              boxShadow: [
                if (isBuffed)
                  BoxShadow(
                    color: const Color.fromARGB(255, 212, 243, 35).withValues(alpha: 0.7),
                    blurRadius: 16,
                    spreadRadius: 5,
                  ),
                if (isSelected) ..._selectedButtonShadows(),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: ClipOval(
                    child: _buildTextureBackground(
                      assetPath: _trainingButtonTexturePath(actionName),
                      fallback: Container(
                        color: isSelected ? Colors.orange : Colors.white,
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: _buttonOverlayTextStyle(
                        size,
                        fontSize: size.width * 0.043,
                      ),
                    ),
                    SizedBox(height: size.height * 0.002),
                    Text(
                      'LVL ${gameManager.facilityLevel}',
                      style: _buttonOverlayTextStyle(
                        size,
                        fontSize: size.width * 0.025,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==============================================
  // Reusable bottom button
  // ==============================================
  Widget _bottomButton(
    Size size, {
    required String label,
    required VoidCallback onTap,
  }) {
    final isSelected =
        gameManager.selectedAction == label.toLowerCase() ||
        (label == 'STORE' && isStorePanelVisible);

    return _PressableScale(
      onTap: onTap,
      child: SizedBox(
        width: size.width * 0.26,
        height: size.height * 0.065,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(
                    color: Colors.white,
                    width: 3,
                  )
                : null,
            boxShadow: isSelected ? _selectedButtonShadows() : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: _buildTextureBackground(
                  assetPath: _bottomButtonTexturePath(label),
                  fallback: Container(color: Colors.teal.shade100),
                ),
              ),
              Text(
                label,
                style: _buttonOverlayTextStyle(
                  size,
                  fontSize: size.width * 0.038,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // PREVIEW LABEL
  // ===============================================================
  Widget _previewStatLabel(
    Size size,
    String previewText,
    Color textColor,
  ) {
    return Expanded(
      child: SizedBox(
        height: size.height * 0.035,
        child: Align(
          alignment: Alignment.center,
          child: _outlinedText(
            text: previewText,
            fillColor: textColor,
            strokeWidth: 2,
            style: TextStyle(
              fontSize: size.width * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // ENERGY BAR WIDGET
  // ===============================================================
  Widget _buildEnergyBar({
    required Size size,
    required int currentEnergy,
    required int previewEnergy,
    required bool showPreview,
  }) {
    return SizedBox(
      width: size.width * 0.68,
      height: size.height * 0.045,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final barWidth = constraints.maxWidth;
          final barHeight = constraints.maxHeight;

          final current = currentEnergy.clamp(0, 100).toDouble();
          final preview = previewEnergy.clamp(0, 100).toDouble();

          final currentWidth = barWidth * (current / 100);
          final previewWidth = barWidth * (preview / 100);

          final isLosing = showPreview && preview < current;
          final isGaining = showPreview && preview > current;

          return Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
              color: Colors.green.shade900,
            ),
            child: Stack(
              children: [
                // =====================================================
                // This animates both energy loss and energy gain.
                // =====================================================
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  width: currentWidth,
                  height: barHeight,
                  color: Colors.greenAccent.shade200,
                ),

                // =====================================================
                // PREVIEW LOSS
                // Orange overlay from preview position to current position.
                // =====================================================
                if (isLosing)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    left: previewWidth,
                    top: 0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      width: currentWidth - previewWidth,
                      height: barHeight,
                      color: const Color.fromARGB(255, 54, 156, 28).withAlpha(170),
                    ),
                  ),

                // =====================================================
                // PREVIEW GAIN
                // Cyan overlay from current position to preview position.
                // =====================================================
                if (isGaining)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    left: currentWidth,
                    top: 0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      width: previewWidth - currentWidth,
                      height: barHeight,
                      color: Colors.cyan.withAlpha(170),
                    ),
                  ),

                // =====================================================
                // PREVIEW TARGET MARKER
                // Red = loss preview
                // Blue = gain preview
                // =====================================================
                if (showPreview)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    left: previewWidth.clamp(0.0, barWidth - 2),
                    top: 0,
                    child: Container(
                      width: 2,
                      height: barHeight,
                      color: isGaining ? Colors.blue : Colors.red,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FloatingStatGain {
  final int id;
  final String text;
  final Color color;
  Alignment alignment;
  final Alignment floatAlignment;
  double opacity;
  double scale;

  _FloatingStatGain({
    required this.id,
    required this.text,
    required this.color,
    required this.alignment,
    required this.floatAlignment,
    required this.opacity,
    required this.scale,
  });
}

class _PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double pressedScale;

  const _PressableScale({
    required this.child,
    required this.onTap,
    this.pressedScale = 0.92,
  });

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (!mounted) return;
    setState(() {
      _isPressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      onTap: () {
        AudioManager.instance.playGameplayButtonClick();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _isPressed ? widget.pressedScale : 1,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
