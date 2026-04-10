import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/audio_manager.dart';
import 'screens/main_menu.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final audioManager = AudioManager.instance;
  await audioManager.init();
  unawaited(audioManager.playMainMenuBgm());

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StatScholar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'PixelVerdana',
      ),
      home: const MainMenu(),
    );
  }
}
