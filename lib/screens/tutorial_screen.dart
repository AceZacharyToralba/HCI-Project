import 'dart:async';

import 'package:flutter/material.dart';

import '../game/audio_manager.dart';
import 'main_menu.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  static const String _mainMenuAssetBase = 'assets/main_menu assets';
  final PageController pageController = PageController();
  final AudioManager audioManager = AudioManager.instance;

  final List<_TutorialTopic> topics = const [
    _TutorialTopic(
      title: 'Overview',
      body:
          'Stat Scholar is a portrait training game inspired by school-life raising sims. You guide one student through three waves, grow their stats, manage their energy, and survive the run by planning each turn carefully.',
    ),
    _TutorialTopic(
      title: 'Goal',
      body:
          'Each wave has its own stat goals. If you reach the goals before the wave ends, you move forward. If you fall short when the turns run out, the run ends. Clear the final wave to complete a full run.',
    ),
    _TutorialTopic(
      title: 'Turns',
      body:
          'Every action uses one turn. A normal rhythm is preview first, then confirm the same action again. After the action resolves, feedback plays, events may happen, and the next-turn transition begins.',
    ),
    _TutorialTopic(
      title: 'Training',
      body:
          'Tap INT, FIT, CHR, or CRT once to preview the gain and energy cost. Tap the same button again to perform that training. Facility level rises with each wave, so later training gets stronger. Buffed training is even stronger than normal.',
    ),
    _TutorialTopic(
      title: 'Energy',
      body:
          'Energy controls your failure rate. High energy keeps training safe. Low energy makes failures brutal. Rest, some events, and store items can refill your energy. Watching the energy bar is one of the most important habits in the game.',
    ),
    _TutorialTopic(
      title: 'Work',
      body:
          'Work gives coins for the store, but it costs energy and can fail. Repeating Work too many times in a row lowers the payout, so it is best used as support for your build instead of your only plan.',
    ),
    _TutorialTopic(
      title: 'Store',
      body:
          'The store is your catch-up and power spike tool. Buy stat boosts, recovery, and protection when you need them. Stronger store decisions matter more in later waves, especially when your goals start climbing.',
    ),
    _TutorialTopic(
      title: 'Events',
      body:
          'Events appear after turns. Some happen automatically, while others offer choices. They can grant stats, energy, or coins, but they can also set you back. Good event luck helps, but planning still wins runs.',
    ),
    _TutorialTopic(
      title: 'Tips',
      body:
          'Ride buffed training when possible, rest before your failure rate spikes, and use the store before a wave check if you are close to the target. Do not rely on Work every turn, and do not ignore event outcomes when planning the next move.',
    ),
  ];

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    unawaited(audioManager.init());
  }

  void _goToTopic(int index) {
    audioManager.playButtonClick();
    setState(() {
      currentIndex = index;
    });
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  void _goBack() {
    audioManager.playButtonClick();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const MainMenu(),
      ),
      (route) => false,
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
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
                    Color(0xFF846243),
                    Color(0xFF4C3626),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.06,
            right: -size.width * 0.08,
            child: Container(
              width: size.width * 0.34,
              height: size.width * 0.34,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                size.width * 0.04,
                size.height * 0.025,
                size.width * 0.04,
                size.height * 0.025,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: size.height * 0.105,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Image.asset(
                                  'assets/gameplay screeen/Pause Panel.png',
                                  fit: BoxFit.fill,
                                  filterQuality: FilterQuality.none,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.055,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Academy Guide',
                                      style: TextStyle(
                                        fontSize: size.width * 0.06,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.brown.shade900,
                                      ),
                                    ),
                                    SizedBox(height: size.height * 0.004),
                                    Text(
                                      'Swipe pages or tap a topic tab.',
                                      style: TextStyle(
                                        fontSize: size.width * 0.032,
                                        color: Colors.brown.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: size.width * 0.025),
                      GestureDetector(
                        onTap: _goBack,
                        child: SizedBox(
                          width: size.width * 0.13,
                          height: size.width * 0.13,
                          child: Image.asset(
                            '$_mainMenuAssetBase/home_icon sprite.png',
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.02),
                  SizedBox(
                    height: size.height * 0.085,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: size.width * 0.005),
                      itemCount: topics.length,
                      itemBuilder: (context, index) {
                        final isSelected = currentIndex == index;

                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: size.width * 0.012),
                          child: GestureDetector(
                            onTap: () => _goToTopic(index),
                            child: SizedBox(
                              width: size.width * 0.28,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Positioned.fill(
                                    child: Image.asset(
                                      isSelected
                                          ? 'assets/gameplay screeen/Auto Event OK Button.png'
                                          : 'assets/gameplay screeen/Event panel buttons.png',
                                      fit: BoxFit.fill,
                                      filterQuality: FilterQuality.none,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: size.width * 0.03,
                                    ),
                                    child: Text(
                                      topics[index].title,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: size.width * 0.032,
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
                      },
                    ),
                  ),
                  SizedBox(height: size.height * 0.015),
                  Expanded(
                    child: PageView.builder(
                      controller: pageController,
                      onPageChanged: (index) {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                      itemCount: topics.length,
                      itemBuilder: (context, index) {
                        final topic = topics[index];

                        return Padding(
                          padding: EdgeInsets.only(
                            left: size.width * 0.015,
                            right: size.width * 0.015,
                            bottom: size.height * 0.01,
                          ),
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
                                padding: EdgeInsets.fromLTRB(
                                  size.width * 0.07,
                                  size.height * 0.04,
                                  size.width * 0.07,
                                  size.height * 0.04,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      topic.title,
                                      style: TextStyle(
                                        fontSize: size.width * 0.068,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.brown.shade900,
                                      ),
                                    ),
                                    SizedBox(height: size.height * 0.025),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: Text(
                                          topic.body,
                                          style: TextStyle(
                                            fontSize: size.width * 0.043,
                                            height: 1.45,
                                            color: Colors.brown.shade800,
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
                      },
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
}

class _TutorialTopic {
  final String title;
  final String body;

  const _TutorialTopic({
    required this.title,
    required this.body,
  });
}
