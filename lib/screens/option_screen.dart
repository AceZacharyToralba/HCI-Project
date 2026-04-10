import 'package:flutter/material.dart';

import '../game/audio_manager.dart';

class OptionScreen extends StatefulWidget {
  const OptionScreen({super.key});

  @override
  State<OptionScreen> createState() => _OptionScreenState();
}

class _OptionScreenState extends State<OptionScreen> {
  final AudioManager audioManager = AudioManager.instance;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.yellow.shade700,
      body: SafeArea(
        child: Center(
          child: Container(
            width: size.width * 0.85,
            padding: EdgeInsets.all(size.width * 0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'OPTIONS',
                  style: TextStyle(
                    fontSize: size.width * 0.07,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: size.height * 0.04),
                Text(
                  'BGM Volume',
                  style: TextStyle(
                    fontSize: size.width * 0.045,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Slider(
                  value: audioManager.bgmVolume,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (value) {
                    audioManager.setBgmVolume(value);
                    setState(() {
                      audioManager.bgmVolume = value;
                    });
                  },
                ),
                SizedBox(height: size.height * 0.02),
                Text(
                  'SFX Volume',
                  style: TextStyle(
                    fontSize: size.width * 0.045,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Slider(
                  value: audioManager.sfxVolume,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (value) {
                    audioManager.setSfxVolume(value);
                    setState(() {
                      audioManager.sfxVolume = value;
                    });
                  },
                ),
                SizedBox(height: size.height * 0.04),
                GestureDetector(
                  onTap: () {
                    audioManager.playButtonClick();
                    Navigator.pop(context);
                  },
                  child: SizedBox(
                    width: size.width * 0.52,
                    height: size.height * 0.085,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            'assets/main_menu_buttons.png',
                            fit: BoxFit.fill,
                            filterQuality: FilterQuality.none,
                          ),
                        ),
                        Text(
                          'BACK',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
