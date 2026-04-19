import 'dart:math';
import '../models/store_item.dart';
import '../models/game_event.dart';
import '../models/character_model.dart';
import 'event_database.dart';

class GameManager {
  final CharacterModel selectedCharacter;
  static const int statCap = 800;

  // ==========================================================
  // GET CURRENT CHARACTER POSE IMAGE
  // Builds the sprite path using:
  // - selected character name
  // - selected action
  //
  // Example output:
  // assets/characters/nerd_guy_work_pose.png
  // ==========================================================
  String getCurrentCharacterPose() {
    // Convert character name into file-friendly format
    final characterFileName = selectedCharacter.name
        .toLowerCase()
        .replaceAll(' ', '_');

    // Decide which action pose to use
    // Default to intellect if nothing is selected yet
    final action = selectedAction ?? 'intellect';

    return 'assets/characters/${characterFileName}_${action}_pose.png';
  }

  // ==========================================================
  // GET CURRENT BACKGROUND BASED ON SELECTED ACTION
  // ==========================================================
  String getCurrentBackground() {
    switch (selectedAction) {
      case 'intellect':
        return 'assets/backgrounds/intellect_bg.png';
      case 'fitness':
        return 'assets/backgrounds/fitness_bg.png';
      case 'charisma':
        return 'assets/backgrounds/charisma_bg.png';
      case 'creativity':
        return 'assets/backgrounds/creativity_bg.png';
      case 'work':
        return 'assets/backgrounds/work_bg.png';
      case 'rest':
        return 'assets/backgrounds/rest_bg.png';
      default:
        return 'assets/backgrounds/intellect_bg.png';
    }
  }
  // ==================================================
  // WAVE / SEMESTER SYSTEM
  // ==================================================
  int currentWave = 1;

  // This will control how many turns each wave has.
  int get maxTurnsForCurrentWave {
    switch (currentWave) {
      case 1:
        return 30;
      case 2:
        return 20;
      case 3:
        return 10;
      default:
        return 0;
    }
  }
  bool gameWon = false;
  bool gameLost = false;
  // ==================================================
  // CORE VALUES
  // ==================================================
  int turnsLeft = 0;
  int energy = 100;
  int coins = 20;

  int intellect = 10;
  int fitness = 8;
  int charisma = 4;
  int creativity = 11;

  int failureRate = 0;
  String buffedStat = 'intellect';
  String? lastTrainingAction;
  int repeatedTrainingCount = 0;

  // ==================================================
  // FINAL SCORE
  // Rebalanced around the higher late-game stat totals.
  // ==================================================
  int get finalScore {
    return intellect +
        fitness +
        charisma +
        creativity +
        (coins * 2) +
        (currentWave * 250) +
        (turnsLeft * 15);
  }

  // ==================================================
  // LAST ACTION RESULT
  // ==================================================
  bool lastActionSucceeded = true;
  String lastActionType = ''; 
  int consecutiveWorkCount = 0;
  int nonWorkTurnsSinceLastWork = 2;

  // ==================================================
  // PAUSE MENU UI STATE
  // ==================================================
  bool isPauseMenuOpen = false;

  // ==================================================
  // AUDIO SETTINGS
  // For future BGM and SFX
  // Range: 0.0 to 1.0
  // ==================================================
  double bgmVolume = 1.0;
  double sfxVolume = 1.0;

  // ==================================================
  // OPEN / CLOSE PAUSE MENU
  // ==================================================
  void openPauseMenu() {
    if (isStoreOpen || isGoalPanelOpen || isEventOpen) return;
    isPauseMenuOpen = true;
  }
  void closePauseMenu() {
    isPauseMenuOpen = false;
  }

  // ==================================================
  // UPDATE AUDIO VALUES
  // ==================================================
  void setBgmVolume(double value) {
    bgmVolume = value;
  }

  void setSfxVolume(double value) {
    sfxVolume = value;
  }

  // ==================================================
  // PERFORMANCE RATING
  // Based on the rebalanced late-game score range.
  // ==================================================
  String get performanceRating {
    if (finalScore >= 2500) {
      return 'S';
    } else if (finalScore >= 2100) {
      return 'A';
    } else if (finalScore >= 1700) {
      return 'B';
    } else if (finalScore >= 1300) {
      return 'C';
    } else {
      return 'D';
    }
  }

  // ==================================================
  // RANDOM EVENT STATE
  // ==================================================
  GameEvent? currentEvent;
  bool isEventOpen = false;
  String eventMessage = '';

  GameEvent? pendingEvent;
  
  // GOAL PANEL
  bool isGoalPanelOpen = false;

  void openGoalPanel() {
    isGoalPanelOpen = true;
  }

  void closeGoalPanel() {
    isGoalPanelOpen = false;
  }

  // ==================================================
  // APPLY EVENT EFFECT
  // This is reusable for:
  // - auto events
  // - choice event options
  // - possibly future systems too
  // ==================================================
  void applyEventEffect(EventEffect effect) {
    _changeStat('intellect', effect.intellectChange);
    _changeStat('fitness', effect.fitnessChange);
    _changeStat('charisma', effect.charismaChange);
    _changeStat('creativity', effect.creativityChange);
    energy += effect.energyChange;
    coins += effect.coinsChange;

    if (effect.setNextActionNoFailure) {
      nextActionNoFailure = true;
    }

    // Prevent coins from going below 0
    if (coins < 0) coins = 0;

    _clampEnergy();
    _updateFailureRate();
  }

  bool get hasPendingEvent => pendingEvent != null;
  int get facilityLevel => currentWave;
  // ==================================================
  // TRIGGER A RANDOM EVENT
  // ==================================================

  void tryTriggerRandomEvent() {
    // chance: 30%
    int roll = random.nextInt(100);
    if (roll >= 30) {
      pendingEvent = null;
      return;
    }

    final allEvents = EventDatabase.allEvents;
    pendingEvent = allEvents[random.nextInt(allEvents.length)];
  }

  void openPendingEvent() {
    if (pendingEvent == null) return;
    currentEvent = pendingEvent;
    pendingEvent = null;
    isEventOpen = true;
  }


  // ==================================================
  // RESOLVE AUTO EVENT
  // Applies the auto effect and closes the event.
  // ==================================================
  void resolveAutoEvent() {
    if (currentEvent == null) return;
    if (currentEvent!.type != EventType.auto) return;
    if (currentEvent!.autoEffect == null) return;

    applyEventEffect(currentEvent!.autoEffect!);
    eventMessage = currentEvent!.title;

    currentEvent = null;
    isEventOpen = false;
  }

  // ==================================================
  // CHOOSE EVENT OPTION
  // Applies the chosen option effect and closes the event.
  // ==================================================
  void chooseEventOption(int optionIndex) {
    if (currentEvent == null) return;
    if (currentEvent!.type != EventType.choice) return;
    if (optionIndex < 0 || optionIndex >= currentEvent!.options.length) return;

    final selectedOption = currentEvent!.options[optionIndex];
    applyEventEffect(selectedOption.effect);
    eventMessage = '${currentEvent!.title}: ${selectedOption.label}';

    currentEvent = null;
    isEventOpen = false;
  }

  final Random random = Random();

  // ==================================================
  // PREVIEW / SELECTION STATE
  // If null, no action is selected.
  // ==================================================
  String? selectedAction = 'intellect';

  GameManager({
    required this.selectedCharacter,
  }) {
    // ==================================================
    // INITIALIZE STARTING VALUES FROM CHARACTER
    // ==================================================
    intellect = selectedCharacter.startingIntellect;
    fitness = selectedCharacter.startingFitness;
    charisma = selectedCharacter.startingCharisma;
    creativity = selectedCharacter.startingCreativity;

    turnsLeft = maxTurnsForCurrentWave;
    _updateFailureRate();
    _pickBuffedStat();
    generateStoreItems();
  }

  bool nextActionNoFailure = false;

  bool get canPlay => turnsLeft > 0 && !gameWon && !gameLost;

  // ==================================================
  // TAP ACTION
  // - First tap = preview
  // - Second tap on same action = execute
  // - Tap different action = switch preview
  // ==================================================

  // ==================================================
  // HELPER: check if the selected action is a training
  // action that should show stat / energy preview.
  // ==================================================
  bool get isTrainingPreview {
    return selectedAction == 'intellect' ||
        selectedAction == 'fitness' ||
        selectedAction == 'charisma' ||
        selectedAction == 'creativity';
  }

  // ==================================================
  // PREVIEW: get stat gain for the currently selected
  // training action.
  // ==================================================
  int getPreviewStatGain() {
    switch (selectedAction) {
      case 'intellect':
        return getTrainingGain('intellect', isBuffed: buffedStat == 'intellect');

      case 'fitness':
        return getTrainingGain('fitness', isBuffed: buffedStat == 'fitness');

      case 'charisma':
        return getTrainingGain('charisma', isBuffed: buffedStat == 'charisma');

      case 'creativity':
        return getTrainingGain('creativity', isBuffed: buffedStat == 'creativity');

      default:
        return 0;
    }
  }

  int getPreviewCoinsGain() {
    if (selectedAction == 'work') {
      return getWorkCoinsReward(forNextWork: true);
    }
    return 0;
  }

  // ==================================================
  // PREVIEW: get energy cost of selected action.
  // For now, only training previews will be used in UI.
  // ==================================================
  int getPreviewEnergyCost() {
    switch (selectedAction) {
      case 'intellect':
        return 10;
      case 'fitness':
        return 15;
      case 'charisma':
        return 20;
      case 'creativity':
        return 12;
      case 'work':
        return 12;
      case 'rest':
        return 0;
      default:
        return 0;
    }
  }

  // ==================================================
  // PREVIEW: get the energy value after the selected
  // action is executed.
  // This does NOT change the real energy.
  // ==================================================
  int getPreviewEnergyValue() {
    int previewEnergy = energy;

    switch (selectedAction) {
      case 'intellect':
        previewEnergy -= 10;
        break;
      case 'fitness':
        previewEnergy -= 15;
        break;
      case 'charisma':
        previewEnergy -= 20;
        break;
      case 'creativity':
        previewEnergy -= 12;
        break;
      case 'work':
        previewEnergy -= 12;
        break;
      case 'rest':
        previewEnergy += 50 + selectedCharacter.restEnergyBonus;
        break;
    }

    if (previewEnergy < 0) previewEnergy = 0;
    if (previewEnergy > 100) previewEnergy = 100;

    return previewEnergy;
  }

  // ==================================================
  // GET CURRENT SEMESTER NAME
  // ==================================================
  String get currentSemesterText {
    switch (currentWave) {
      case 1:
        return '1st Semester';
      case 2:
        return '2nd Semester';
      case 3:
        return 'Final Semester';
      default:
        return '';
    }
  }

  // ==================================================
  // CURRENT SEMESTER GOALS
  // These are the target stats the player must reach
  // before the semester ends.
  // ==================================================
  int get intellectGoal {
    switch (currentWave) {
      case 1:
        return 145;
      case 2:
        return 390;
      case 3:
        return 700;
      default:
        return 0;
    }
  }

  int get fitnessGoal {
    switch (currentWave) {
      case 1:
        return 130;
      case 2:
        return 340;
      case 3:
        return 640;
      default:
        return 0;
    }
  }

  int get charismaGoal {
    switch (currentWave) {
      case 1:
        return 120;
      case 2:
        return 320;
      case 3:
        return 610;
      default:
        return 0;
    }
  }

  int get creativityGoal {
    switch (currentWave) {
      case 1:
        return 135;
      case 2:
        return 350;
      case 3:
        return 670;
      default:
        return 0;
    }
  }

  // ==================================================
  // CHECK IF CURRENT SEMESTER GOALS ARE MET
  // ==================================================
  bool get hasMetCurrentGoals {
    return hasMetGoalForStat('intellect') &&
        hasMetGoalForStat('fitness') &&
        hasMetGoalForStat('charisma') &&
        hasMetGoalForStat('creativity');
  }

  // Keep goal checks centralized so the wave-end logic and the goal panel
  // always use the exact same requirement.
  bool hasMetGoalForStat(String statName) {
    switch (statName) {
      case 'intellect':
        return intellect >= intellectGoal;
      case 'fitness':
        return fitness >= fitnessGoal;
      case 'charisma':
        return charisma >= charismaGoal;
      case 'creativity':
        return creativity >= creativityGoal;
      default:
        return false;
    }
  }

  // ==================================================
  // PREVIEW: returns stat preview text only for the
  // correct stat panel entry.
  //
  // Example:
  // if selectedAction == 'intellect', then:
  // getPreviewTextForStat('intellect') => +15
  // getPreviewTextForStat('fitness') => ''
  // ==================================================
  String getPreviewTextForStat(String statName) {
    if (selectedAction == statName && isTrainingPreview) {
      return '+${getPreviewStatGain()}';
    }
    return '';
  }

  void tapAction(String actionName) {
  if (!canPlay) return;

  // Same action tapped again -> execute it
  if (selectedAction == actionName) {
    _executeAction(actionName);

    // IMPORTANT:
    // Keep the same action selected after execution
    // so the player does not need to preview again.
    selectedAction = actionName;
  } else {
    // Different action tapped -> only preview it
    selectedAction = actionName;
  }
}

// ==================================================
// STORE SYSTEM
// ==================================================
List<StoreItem> storeItems = [];
int turnsSinceLastRefresh = 0;
bool isStoreOpen = false;

int get displayedFailureRate {
  if (nextActionNoFailure) {
    return 0;
  }
  return failureRate;
}

  // ==================================================
  // EXECUTE ACTION
  // ==================================================
  void _executeAction(String actionName) {
    switch (actionName) {
      case 'intellect':
        trainIntellect();
        break;
      case 'fitness':
        trainFitness();
        break;
      case 'charisma':
        trainCharisma();
        break;
      case 'creativity':
        trainCreativity();
        break;
      case 'work':
        work();
        break;
      case 'rest':
        rest();
        break;
    }
  }

  // ==================================================
  // ACTUAL ACTION METHODS
  // ==================================================

  int applyGrowth(int base, double rate) {
    return (base * (1 + rate)).round();
  }

  int _getTrainingBaseGain(String statName, {required bool isBuffed}) {
    // Wave 2+ needs a much sharper gain jump so the later goals stay reachable.
    final facilityBonus = _getFacilityBonus();

    switch (statName) {
      case 'intellect':
        return (isBuffed ? 24 : 16) + facilityBonus;
      case 'fitness':
        return (isBuffed ? 22 : 14) + facilityBonus;
      case 'charisma':
        return (isBuffed ? 20 : 12) + facilityBonus;
      case 'creativity':
        return (isBuffed ? 23 : 15) + facilityBonus;
      default:
        return facilityBonus;
    }
  }

  int _getFacilityBonus() {
    switch (facilityLevel) {
      case 1:
        return 0;
      case 2:
        return 40;
      case 3:
        return 98;
      default:
        return 0;
    }
  }

  double _getGrowthRateForStat(String statName) {
    switch (statName) {
      case 'intellect':
        return selectedCharacter.intellectGrowthRate;
      case 'fitness':
        return selectedCharacter.fitnessGrowthRate;
      case 'charisma':
        return selectedCharacter.charismaGrowthRate;
      case 'creativity':
        return selectedCharacter.creativityGrowthRate;
      default:
        return 0;
    }
  }

  int _applyRepeatedTrainingPenalty(String statName, int gain) {
    if (lastTrainingAction != statName) return gain;

    // Repeating the same class too many times in a row trims gains a bit.
    if (repeatedTrainingCount >= 4) {
      return max(1, (gain * 0.75).round());
    }
    if (repeatedTrainingCount >= 2) {
      return max(1, (gain * 0.88).round());
    }
    return gain;
  }

  int getTrainingGain(String statName, {required bool isBuffed}) {
    final baseGain = _getTrainingBaseGain(statName, isBuffed: isBuffed);
    final growthAdjusted = applyGrowth(baseGain, _getGrowthRateForStat(statName));
    return _applyRepeatedTrainingPenalty(statName, growthAdjusted);
  }

  int _getBaseWorkCoinsReward() {
    switch (currentWave) {
      case 1:
        return 42;
      case 2:
        return 74;
      case 3:
        return 236;
      default:
        return 42;
    }
  }

  int _getSingleStatStoreBoost() {
    switch (currentWave) {
      case 1:
        return 75;
      case 2:
        return 110;
      case 3:
        return 155;
      default:
        return 75;
    }
  }

  int _getCatchUpBoostAmount() {
    switch (currentWave) {
      case 2:
        return 135;
      case 3:
        return 190;
      default:
        return 90;
    }
  }

  int _getAllStatsBoostAmount() {
    switch (currentWave) {
      case 2:
        return 35;
      case 3:
        return 55;
      default:
        return 25;
    }
  }

  int _getFinalsPackAmount() {
    switch (currentWave) {
      case 3:
        return 75;
      default:
        return 45;
    }
  }

  int getWorkCoinsReward({bool forNextWork = false}) {
    final baseReward = _getBaseWorkCoinsReward();

    final projectedWorkCount = forNextWork
        ? _getProjectedConsecutiveWorkCount()
        : consecutiveWorkCount;

    if (projectedWorkCount <= 3) {
      return baseReward;
    }

    // Repeated work gets worse quickly so coins stop being the always-safe option.
    final penaltyMultiplier = pow(0.7, projectedWorkCount - 3).toDouble();
    return max(1, (baseReward * penaltyMultiplier).round());
  }

  int _getProjectedConsecutiveWorkCount() {
    if (nonWorkTurnsSinceLastWork >= 2) {
      return 1;
    }
    return consecutiveWorkCount + 1;
  }

  void _trackWorkUsage(String actionName) {
    if (actionName == 'work') {
      if (nonWorkTurnsSinceLastWork >= 2) {
        consecutiveWorkCount = 1;
      } else {
        consecutiveWorkCount++;
      }
      nonWorkTurnsSinceLastWork = 0;
      return;
    }

    if (nonWorkTurnsSinceLastWork < 99) {
      nonWorkTurnsSinceLastWork++;
    }
  }

  void _trackTrainingVariety(String statName) {
    if (lastTrainingAction == statName) {
      repeatedTrainingCount++;
    } else {
      lastTrainingAction = statName;
      repeatedTrainingCount = 1;
    }
  }

  void _resetTrainingVariety() {
    lastTrainingAction = null;
    repeatedTrainingCount = 0;
  }

  void trainIntellect() {
    _handleTraining(
      statName: 'intellect',
      energyCost: 10,
      failPenalty: 8,
    );
  }

  void trainFitness() {
    _handleTraining(
      statName: 'fitness',
      energyCost: 15,
      failPenalty: 8,
    );
  }

  void trainCharisma() {
    _handleTraining(
      statName: 'charisma',
      energyCost: 20,
      failPenalty: 7,
    );
  }

  void trainCreativity() {
    _handleTraining(
      statName: 'creativity',
      energyCost: 12,
      failPenalty: 8,
    );
  }

  void rest() {
    if (!canPlay) return;
    _resetTrainingVariety();
    lastActionType = 'rest';
    lastActionSucceeded = true;

    int roll = random.nextInt(100);

    if (roll < 70) {
      energy += 50 + selectedCharacter.restEnergyBonus;
    } else if (roll < 90) {
      energy += 70 + selectedCharacter.restEnergyBonus;
    } else {
      energy += 30 + selectedCharacter.restEnergyBonus;
      _reduceRandomStat(5);
    }

    _clampEnergy();
    _useTurn();
  }

  // ==================================================
  // WORK ACTION
  // ==================================================
  void work() {
    if (!canPlay) return;
    _resetTrainingVariety();

    bool failed = _didTrainingFail();

    // Save feedback info
    lastActionType = 'work';
    lastActionSucceeded = !failed;

    if (failed) {
      energy -= 25;
    } else {
      _trackWorkUsage('work');
      coins += getWorkCoinsReward();
      energy -= 12;
    }

    if (failed) {
      _trackWorkUsage('work');
    }

  _clampEnergy();
  _useTurn();
}

  void openStore() {
    isStoreOpen = true;
  }

  void closeStore() {
    isStoreOpen = false;
  }

  // ==================================================
  // HANDLE TRAINING
  // ==================================================
  void _handleTraining({
    required String statName,
    required int energyCost,
    required int failPenalty,
  }) {
    if (!canPlay) return;

    energy -= energyCost;
    _clampEnergy();

    bool failed = _didTrainingFail();
    _trackTrainingVariety(statName);

    lastActionType = statName;
    lastActionSucceeded = !failed;

    if (failed) {
      _changeStat(statName, -failPenalty);
    } else {
      int gain = getTrainingGain(
        statName,
        isBuffed: buffedStat == statName,
      );
      _changeStat(statName, gain);
    }

    _useTurn();
  }

  bool _didTrainingFail() {
    int roll = random.nextInt(100);
    if (nextActionNoFailure) {
      nextActionNoFailure = false;
      return false;
    }
    return roll < failureRate;
  }

  void _updateFailureRate() {
    if (energy >= 55) {
      failureRate = 0;
    } else if (energy >= 48) {
      failureRate = 15;
    } else if (energy >= 36) {
      failureRate = 35;
    } else if (energy >= 28) {
      failureRate = 55;
    } else if (energy >= 14) {
      failureRate = 80;
    } else {
      failureRate = 99;
    }
  }

  void _pickBuffedStat() {
    List<String> stats = [
      'intellect',
      'fitness',
      'charisma',
      'creativity',
    ];

    buffedStat = stats[random.nextInt(stats.length)];
  }

  void _useTurn() {
    if (turnsLeft > 0) {
      turnsLeft--;
    }

    if (lastActionType != 'work') {
      _trackWorkUsage(lastActionType);
    }

    _updateFailureRate();

    // Track turns for store refresh
    turnsSinceLastRefresh++;
    if (turnsSinceLastRefresh >= 5) {
      generateStoreItems();
      turnsSinceLastRefresh = 0;
    }

    // ==================================================
    // CHECK IF WAVE ENDED
    // ==================================================
    if (turnsLeft == 0) {
      _handleWaveEnd();
    } else {
      _pickBuffedStat();
    }

    if (!gameWon && !gameLost && turnsLeft > 0) {
      tryTriggerRandomEvent();
    }
  }

  // ==================================================
  // HANDLE WAVE END
  // ==================================================
  void _handleWaveEnd() {
    // If the player failed the goals, they lose immediately.
    if (!hasMetCurrentGoals) {
      gameLost = true;
      turnsLeft = 0;
      return;
    }

    // If this was the final wave and goals were met, player wins.
    if (currentWave == 3) {
      gameWon = true;
      turnsLeft = 0;
      return;
    }

    // Otherwise, go to the next wave.
    currentWave++;
    turnsLeft = maxTurnsForCurrentWave;

    // Pick a new buffed stat for the new semester.
    _pickBuffedStat();
  }

  void addStatBoost(String statName, int amount) {
    _changeStat(statName, amount);
  }

  void restoreEnergy(int amount) {
    energy += amount;
    _clampEnergy();
    _updateFailureRate();
  }

  void boostLowestStat(int amount) {
    final stats = <String, int>{
      'intellect': intellect,
      'fitness': fitness,
      'charisma': charisma,
      'creativity': creativity,
    };

    final lowestStat = stats.entries.reduce(
      (currentLowest, entry) =>
          entry.value < currentLowest.value ? entry : currentLowest,
    ).key;

    _changeStat(lowestStat, amount);
  }

  void boostAllStats(int amount) {
    _changeStat('intellect', amount);
    _changeStat('fitness', amount);
    _changeStat('charisma', amount);
    _changeStat('creativity', amount);
  }

  void _changeStat(String statName, int amount) {
    switch (statName) {
      case 'intellect':
        intellect += amount;
        intellect = intellect.clamp(0, statCap);
        break;
      case 'fitness':
        fitness += amount;
        fitness = fitness.clamp(0, statCap);
        break;
      case 'charisma':
        charisma += amount;
        charisma = charisma.clamp(0, statCap);
        break;
      case 'creativity':
        creativity += amount;
        creativity = creativity.clamp(0, statCap);
        break;
    }
  }

  void _reduceRandomStat(int amount) {
    List<String> stats = [
      'intellect',
      'fitness',
      'charisma',
      'creativity',
    ];

    String chosenStat = stats[random.nextInt(stats.length)];
    _changeStat(chosenStat, -amount);
  }

  void _clampEnergy() {
    if (energy < 0) {
      energy = 0;
    }
    if (energy > 100) {
      energy = 100;
    }
  }

  // ==================================================
  // GENERATE STORE ITEMS
  // Randomly fills the store with 10 items
  // ==================================================
  void generateStoreItems() {
    storeItems.clear();

    final singleStatBoost = _getSingleStatStoreBoost();
    final catchUpBoost = _getCatchUpBoostAmount();
    final allStatsBoost = _getAllStatsBoostAmount();
    final finalsPackBoost = _getFinalsPackAmount();

    final allItems = <StoreItem>[
      StoreItem(
        name: 'INT +$singleStatBoost',
        cost: 90,
        applyEffect: (gm) => gm.addStatBoost('intellect', singleStatBoost),
      ),
      StoreItem(
        name: 'FIT +$singleStatBoost',
        cost: 90,
        applyEffect: (gm) => gm.addStatBoost('fitness', singleStatBoost),
      ),
      StoreItem(
        name: 'CHR +$singleStatBoost',
        cost: 90,
        applyEffect: (gm) => gm.addStatBoost('charisma', singleStatBoost),
      ),
      StoreItem(
        name: 'CRT +$singleStatBoost',
        cost: 90,
        applyEffect: (gm) => gm.addStatBoost('creativity', singleStatBoost),
      ),
      StoreItem(
        name: 'Energy +60',
        cost: 75,
        applyEffect: (gm) => gm.restoreEnergy(60),
      ),
      StoreItem(
        name: 'Energy Full',
        cost: 115,
        applyEffect: (gm) => gm.restoreEnergy(100),
      ),
      StoreItem(
        name: 'Failure = 0%',
        cost: 95,
        applyEffect: (gm) {
          gm.nextActionNoFailure = true;
        },
      ),
    ];

    if (currentWave >= 2) {
      allItems.addAll([
        StoreItem(
          name: 'Catch-Up Boost +$catchUpBoost',
          cost: 120,
          applyEffect: (gm) => gm.boostLowestStat(catchUpBoost),
        ),
        StoreItem(
          name: 'All Stats +$allStatsBoost',
          cost: 130,
          applyEffect: (gm) => gm.boostAllStats(allStatsBoost),
        ),
      ]);
    }

    if (currentWave >= 3) {
      allItems.addAll([
        StoreItem(
          name: 'Finals Pack +$finalsPackBoost All',
          cost: 180,
          applyEffect: (gm) => gm.boostAllStats(finalsPackBoost),
        ),
        StoreItem(
          name: 'Perfect Focus x2',
          cost: 175,
          applyEffect: (gm) {
            gm.nextActionNoFailure = true;
            gm.restoreEnergy(25);
          },
        ),
      ]);
    }

    allItems.shuffle(random);

    // Show a tighter, more meaningful store lineup each refresh.
    final itemCount = min(8, allItems.length);
    for (int i = 0; i < itemCount; i++) {
      final baseItem = allItems[i];
      storeItems.add(
        StoreItem(
          name: baseItem.name,
          cost: baseItem.cost,
          applyEffect: baseItem.applyEffect,
        ),
      );
    }
  }

// ==================================================
// BUY ITEM
// ==================================================
void buyItem(int index) {
  if (index < 0 || index >= storeItems.length) return;

  final item = storeItems[index];

  if (item.isBought) return;

  if (coins < item.cost) return;

  coins -= item.cost;
  item.applyEffect(this);
  _clampEnergy();
  _updateFailureRate();
  item.isBought = true;
}
}
