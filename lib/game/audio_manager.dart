import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioManager instance = AudioManager._internal();

  factory AudioManager() => instance;

  AudioManager._internal();

  static const String _mainMenuBgmPath =
      'audio/bgm/main_menu_background_Music.mp3';
  static const String _leaderboardBgmPath =
      'audio/bgm/leaderboard_background_music.mp3';
  static const String _characterSelectionPath =
      'audio/sfx/play_button_character_selection.mp3';

  double bgmVolume = 1.0;
  double sfxVolume = 1.0;
  bool isMuted = false;
  bool isBgmMuted = false;
  bool isSfxMuted = false;

  bool _isInitialized = false;
  Future<void>? _initFuture;
  String? _currentBgmPath;

  DateTime? _lastButtonClickTime;
  DateTime? _lastGameplayButtonClickTime;
  final Duration _buttonClickCooldown = const Duration(milliseconds: 70);
  final Duration _gameplayButtonClickCooldown =
      const Duration(milliseconds: 50);

  final AudioCache _audioCache = AudioCache(prefix: 'assets/');
  final AudioPlayer _bgmPlayer = AudioPlayer(playerId: 'bgm_player');
  final AudioPlayer _characterSelectionPlayer =
      AudioPlayer(playerId: 'character_selection_player');
  final AudioContext _mixingAudioContext = AudioContextConfig(
    focus: AudioContextConfigFocus.mixWithOthers,
  ).build();

  AudioPool? _menuTapPool;
  AudioPool? _gameplayClickPool;
  AudioPool? _trainingSuccessPool;
  AudioPool? _trainingFailedPool;
  AudioPool? _statsGainedPool;
  AudioPool? _coinsGainedPool;
  AudioPool? _eventPopupPool;
  AudioPool? _storeOpenPool;
  AudioPool? _turnTransitionPool;

  Future<void> init() async {
    if (_isInitialized) return;
    if (_initFuture != null) {
      await _initFuture;
      return;
    }

    _initFuture = _initializeAudio();
    await _initFuture;
  }

  Future<void> _initializeAudio() async {
    try {
      await _bgmPlayer.setAudioContext(_mixingAudioContext);
      await _characterSelectionPlayer.setAudioContext(_mixingAudioContext);
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _characterSelectionPlayer.setReleaseMode(ReleaseMode.stop);

      await _audioCache.loadAll(<String>[
        _mainMenuBgmPath,
        _leaderboardBgmPath,
        'audio/bgm/first_semester_bg_music.mp3',
        'audio/bgm/second_semester_bg_music.mp3',
        'audio/bgm/third_semester_bg_music.mp3',
        'audio/sfx/tap_Sound.wav',
        'audio/sfx/button_click.mp3',
        _characterSelectionPath,
        'audio/sfx/training_success.mp3',
        'audio/sfx/training_failed.mp3',
        'audio/sfx/stats_gained.mp3',
        'audio/sfx/coins_gained.mp3',
        'audio/sfx/event_pop_up.mp3',
        'audio/sfx/opening_store.mp3',
        'audio/sfx/turn_transition.mp3',
      ]);

      _menuTapPool = await _createPool(
        'audio/sfx/tap_Sound.wav',
        maxPlayers: 1,
      );
      _gameplayClickPool = await _createPool(
        'audio/sfx/button_click.mp3',
        maxPlayers: 1,
      );
      _trainingSuccessPool =
          await _createPool('audio/sfx/training_success.mp3');
      _trainingFailedPool =
          await _createPool('audio/sfx/training_failed.mp3');
      _statsGainedPool = await _createPool('audio/sfx/stats_gained.mp3');
      _coinsGainedPool = await _createPool('audio/sfx/coins_gained.mp3');
      _eventPopupPool = await _createPool('audio/sfx/event_pop_up.mp3');
      _storeOpenPool = await _createPool('audio/sfx/opening_store.mp3');
      _turnTransitionPool = await _createPool('audio/sfx/turn_transition.mp3');

      _isInitialized = true;
    } finally {
      _initFuture = null;
    }
  }

  Future<AudioPool> _createPool(
    String path, {
    int maxPlayers = 3,
  }) {
    return AudioPool.create(
      source: AssetSource(path),
      audioCache: _audioCache,
      audioContext: _mixingAudioContext,
      maxPlayers: maxPlayers,
      minPlayers: 1,
      playerMode: PlayerMode.lowLatency,
    );
  }

  Future<void> _playBgm(String path) async {
    await init();

    if (_currentBgmPath == path) {
      await _bgmPlayer.setVolume(_effectiveBgmVolume);
      if (_bgmPlayer.state != PlayerState.playing) {
        await _bgmPlayer.resume();
      }
      return;
    }

    await _bgmPlayer.stop();
    await _bgmPlayer.play(
      AssetSource(path),
      volume: _effectiveBgmVolume,
    );
    _currentBgmPath = path;
  }

  Future<void> playMainMenuBgm() async {
    await _playBgm(_mainMenuBgmPath);
  }

  Future<void> playLeaderboardBgm() async {
    await _playBgm(_leaderboardBgmPath);
  }

  Future<void> playSemesterBgm(int wave) async {
    final path = switch (wave) {
      1 => 'audio/bgm/first_semester_bg_music.mp3',
      2 => 'audio/bgm/second_semester_bg_music.mp3',
      _ => 'audio/bgm/third_semester_bg_music.mp3',
    };

    await _playBgm(path);
  }

  Future<void> stopBgm() async {
    await _bgmPlayer.stop();
    _currentBgmPath = null;
  }

  void playButtonClick() {
    if (_areSfxMuted) return;
    final now = DateTime.now();

    if (_lastButtonClickTime != null &&
        now.difference(_lastButtonClickTime!) < _buttonClickCooldown) {
      return;
    }

    _lastButtonClickTime = now;
    _startPool(_menuTapPool, 'audio/sfx/tap_Sound.wav');
  }

  void playGameplayButtonClick() {
    if (_areSfxMuted) return;
    final now = DateTime.now();

    if (_lastGameplayButtonClickTime != null &&
        now.difference(_lastGameplayButtonClickTime!) <
            _gameplayButtonClickCooldown) {
      return;
    }

    _lastGameplayButtonClickTime = now;
    _startPool(_gameplayClickPool, 'audio/sfx/button_click.mp3');
  }

  Future<void> playCharacterSelectionStart() async {
    await init();
    if (_areSfxMuted) return;

    try {
      await _characterSelectionPlayer.stop();
      await _characterSelectionPlayer.play(
        AssetSource(_characterSelectionPath),
        volume: sfxVolume,
      );

      await Future.any(<Future<void>>[
        _characterSelectionPlayer.onPlayerComplete.first.then((_) {}),
        Future<void>.delayed(const Duration(seconds: 4)),
      ]);
    } catch (_) {
      await Future<void>.delayed(const Duration(milliseconds: 700));
    }
  }

  void playTrainingSuccess() {
    if (_areSfxMuted) return;
    _startPool(_trainingSuccessPool, 'audio/sfx/training_success.mp3');
  }

  void playTrainingFailed() {
    if (_areSfxMuted) return;
    _startPool(_trainingFailedPool, 'audio/sfx/training_failed.mp3');
  }

  void playStatsGained() {
    if (_areSfxMuted) return;
    _startPool(_statsGainedPool, 'audio/sfx/stats_gained.mp3');
  }

  void playCoinsGained() {
    if (_areSfxMuted) return;
    _startPool(_coinsGainedPool, 'audio/sfx/coins_gained.mp3');
  }

  void playEventPopup() {
    if (_areSfxMuted) return;
    _startPool(_eventPopupPool, 'audio/sfx/event_pop_up.mp3');
  }

  void playStoreOpen() {
    if (_areSfxMuted) return;
    _startPool(_storeOpenPool, 'audio/sfx/opening_store.mp3');
  }

  void playTurnTransition() {
    if (_areSfxMuted) return;
    _startPool(_turnTransitionPool, 'audio/sfx/turn_transition.mp3');
  }

  Future<void> setBgmVolume(double value) async {
    bgmVolume = value;
    await _bgmPlayer.setVolume(_effectiveBgmVolume);
  }

  void setSfxVolume(double value) {
    sfxVolume = value;
  }

  Future<void> setMuted(bool value) async {
    isMuted = value;
    await _bgmPlayer.setVolume(_effectiveBgmVolume);
  }

  Future<void> setBgmMuted(bool value) async {
    isBgmMuted = value;
    await _bgmPlayer.setVolume(_effectiveBgmVolume);
  }

  void setSfxMuted(bool value) {
    isSfxMuted = value;
  }

  bool get _areSfxMuted => isMuted || isSfxMuted;
  double get _effectiveBgmVolume => (isMuted || isBgmMuted) ? 0.0 : bgmVolume;

  void _startPool(AudioPool? pool, String fallbackPath) {
    if (pool != null) {
      unawaited(pool.start(volume: sfxVolume));
      return;
    }

    unawaited(_playFallbackSfx(fallbackPath));
  }

  Future<void> _playFallbackSfx(String path) async {
    final player = AudioPlayer();

    try {
      await player.setAudioContext(_mixingAudioContext);
      await player.setReleaseMode(ReleaseMode.stop);
      await player.play(
        AssetSource(path),
        volume: sfxVolume,
      );
    } catch (_) {
      // Ignore fallback SFX failures so UI interactions keep moving.
    }
  }

}
