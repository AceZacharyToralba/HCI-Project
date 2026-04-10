// =============================================================
// EVENT TYPE
// auto   = no player choice, just happens
// choice = player must choose an option
// =============================================================
enum EventType {
  auto,
  choice,
}

// =============================================================
// EVENT EFFECT
// This describes what an event or option will do.
// Any field can be 0 if unused.
// =============================================================
class EventEffect {
  final int intellectChange;
  final int fitnessChange;
  final int charismaChange;
  final int creativityChange;
  final int energyChange;
  final int coinsChange;
  final bool setNextActionNoFailure;

  const EventEffect({
    this.intellectChange = 0,
    this.fitnessChange = 0,
    this.charismaChange = 0,
    this.creativityChange = 0,
    this.energyChange = 0,
    this.coinsChange = 0,
    this.setNextActionNoFailure = false,
  });
}

// =============================================================
// EVENT OPTION
// Used only for choice events.
// Example:
// label: "Study seriously"
// effect: +10 intellect, -10 energy
// =============================================================
class EventOption {
  final String label;
  final EventEffect effect;

  const EventOption({
    required this.label,
    required this.effect,
  });
}

// =============================================================
// GAME EVENT
// For auto events:
// - use autoEffect
// - options can stay empty
//
// For choice events:
// - use options
// - autoEffect can stay null
// =============================================================
class GameEvent {
  final String id;
  final String title;
  final String description;
  final EventType type;
  final EventEffect? autoEffect;
  final List<EventOption> options;

  const GameEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.autoEffect,
    this.options = const [],
  });
}