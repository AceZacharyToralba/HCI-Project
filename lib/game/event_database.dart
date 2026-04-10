import '../models/game_event.dart';

// =============================================================
// EVENT DATABASE
// Add future events here.
// This is the only file you should need to expand often.
// =============================================================
class EventDatabase {
  static const List<GameEvent> allEvents = [
    // =========================================================
    // AUTO EVENTS
    // =========================================================
    GameEvent(
      id: 'late_alarm',
      title: 'Late Alarm',
      description: 'You woke up late and rushed to class.',
      type: EventType.auto,
      autoEffect: EventEffect(
        energyChange: -10,
      ),
    ),

    GameEvent(
      id: 'creative_burst',
      title: 'Creative Burst',
      description: 'A sudden idea inspires you.',
      type: EventType.auto,
      autoEffect: EventEffect(
        creativityChange: 18,
      ),
    ),

    GameEvent(
      id: 'pop_quiz',
      title: 'Pop Quiz',
      description: 'A surprise quiz drains your focus.',
      type: EventType.auto,
      autoEffect: EventEffect(
        intellectChange: -12,
        energyChange: -12,
      ),
    ),

    GameEvent(
      id: 'morning_jog',
      title: 'Morning Jog',
      description: 'You start the day with a strong burst of momentum.',
      type: EventType.auto,
      autoEffect: EventEffect(
        fitnessChange: 16,
        energyChange: -6,
      ),
    ),

    GameEvent(
      id: 'club_shoutout',
      title: 'Club Shoutout',
      description: 'Your classmates praise your recent effort.',
      type: EventType.auto,
      autoEffect: EventEffect(
        charismaChange: 16,
      ),
    ),

    GameEvent(
      id: 'burnout',
      title: 'Burnout',
      description: 'You pushed too hard and feel mentally exhausted.',
      type: EventType.auto,
      autoEffect: EventEffect(
        energyChange: -18,
        creativityChange: -10,
      ),
    ),

    GameEvent(
      id: 'lucky_coupon',
      title: 'Lucky Coupon',
      description: 'You find a discount coupon tucked into your notebook.',
      type: EventType.auto,
      autoEffect: EventEffect(
        coinsChange: 40,
      ),
    ),

    // =========================================================
    // CHOICE EVENTS
    // =========================================================
    GameEvent(
      id: 'study_group',
      title: 'Study Group',
      description: 'A classmate invites you to review together.',
      type: EventType.choice,
      options: [
        EventOption(
          label: 'Study seriously',
          effect: EventEffect(
            intellectChange: 20,
            energyChange: -12,
          ),
        ),
        EventOption(
          label: 'Chat casually',
          effect: EventEffect(
            charismaChange: 14,
            energyChange: 4,
          ),
        ),
      ],
    ),

    GameEvent(
      id: 'free_period',
      title: 'Free Period',
      description: 'You suddenly have some free time.',
      type: EventType.choice,
      options: [
        EventOption(
          label: 'Take a short rest',
          effect: EventEffect(
            energyChange: 20,
          ),
        ),
        EventOption(
          label: 'Practice something creative',
          effect: EventEffect(
            creativityChange: 18,
            energyChange: -8,
          ),
        ),
      ],
    ),

    GameEvent(
      id: 'after_school_offer',
      title: 'After-School Offer',
      description: 'A senior offers to help you after class.',
      type: EventType.choice,
      options: [
        EventOption(
          label: 'Ask for tutoring',
          effect: EventEffect(
            intellectChange: 24,
            energyChange: -10,
          ),
        ),
        EventOption(
          label: 'Ask for gym drills',
          effect: EventEffect(
            fitnessChange: 24,
            energyChange: -10,
          ),
        ),
        EventOption(
          label: 'Save your energy',
          effect: EventEffect(
            energyChange: 10,
          ),
        ),
      ],
    ),

    GameEvent(
      id: 'festival_invite',
      title: 'Festival Invite',
      description: 'Your friends invite you to help with the school festival.',
      type: EventType.choice,
      options: [
        EventOption(
          label: 'Lead the booth',
          effect: EventEffect(
            charismaChange: 24,
            coinsChange: 20,
            energyChange: -10,
          ),
        ),
        EventOption(
          label: 'Design decorations',
          effect: EventEffect(
            creativityChange: 26,
            energyChange: -12,
          ),
        ),
        EventOption(
          label: 'Skip it',
          effect: EventEffect(
            charismaChange: -8,
          ),
        ),
      ],
    ),

    GameEvent(
      id: 'library_shortcut',
      title: 'Library Shortcut',
      description: 'You find an old exam archive hidden in the library.',
      type: EventType.choice,
      options: [
        EventOption(
          label: 'Use it carefully',
          effect: EventEffect(
            intellectChange: 18,
            setNextActionNoFailure: true,
          ),
        ),
        EventOption(
          label: 'Spend the time resting',
          effect: EventEffect(
            energyChange: 18,
          ),
        ),
      ],
    ),

    GameEvent(
      id: 'overbooked_day',
      title: 'Overbooked Day',
      description: 'Too many tasks hit you at once.',
      type: EventType.choice,
      options: [
        EventOption(
          label: 'Push through',
          effect: EventEffect(
            intellectChange: 15,
            fitnessChange: 15,
            energyChange: -18,
          ),
        ),
        EventOption(
          label: 'Recover first',
          effect: EventEffect(
            energyChange: 12,
            coinsChange: -10,
          ),
        ),
        EventOption(
          label: 'Ask a friend for help',
          effect: EventEffect(
            charismaChange: 14,
            creativityChange: 10,
            energyChange: -6,
          ),
        ),
      ],
    ),
  ];
}
