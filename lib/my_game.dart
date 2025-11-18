import 'dart:async';
import 'dart:math';

import 'package:cosmic_havoc/components/asteroid.dart';
import 'package:cosmic_havoc/components/audio_manager.dart';
import 'package:cosmic_havoc/components/pickup.dart';
import 'package:cosmic_havoc/components/player.dart';
import 'package:cosmic_havoc/components/player_health.dart';
import 'package:cosmic_havoc/components/shoot_button.dart';
import 'package:cosmic_havoc/components/pause_button.dart';
import 'package:cosmic_havoc/components/parallax_background.dart';
import 'package:cosmic_havoc/components/wave_manager.dart';
import 'package:cosmic_havoc/utils/highscore_manager.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class MyGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  late Player player;
  late JoystickComponent joystick;
  late SpawnComponent _pickupSpawner;
  late WaveManager _waveManager;
  final Random _random = Random();
  late ShootButton _shootButton;
  late PauseButton _pauseButton;
  int _score = 0;
  late TextComponent _scoreDisplay;
  late TextComponent _comboDisplay;
  late PlayerHealth _playerHealth;
  final List<String> playerColors = ['blue', 'red', 'green', 'purple'];
  int playerColorIndex = 0;
  late final AudioManager audioManager;

  late RectangleComponent _flashScreen;
  int _combo = 0;

  int get score => _score;

  @override
  FutureOr<void> onLoad() async {
    await Flame.device.fullScreen();
    await Flame.device.setPortrait();

    add(ParallaxBackground());

    audioManager = AudioManager();
    await add(audioManager);

    return super.onLoad();
  }

  void startGame() async {
    await _createJoystick();
    await _createPlayer();
    _createHud();
    _createShootButton();

    _pauseButton = PauseButton()..priority = 10;
    add(_pauseButton);

    _waveManager = WaveManager();
    add(_waveManager);

    _createPickupSpawner();

    // Initialize flash screen as transparent
    _flashScreen = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.red.withOpacity(0.0),
      priority: 5,
    );
    add(_flashScreen);
  }

  void _createHud() {
    _score = 0;
    _combo = 0;
    _scoreDisplay = TextComponent(
      text: '0',
      anchor: Anchor.topRight,
      position: Vector2(size.x - 20, 20),
      priority: 11,
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 32),
      ),
    );
    add(_scoreDisplay);

    _comboDisplay = TextComponent(
      text: '',
      anchor: Anchor.topRight,
      position: Vector2(size.x - 20, 60),
      priority: 11,
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.yellow, fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
    add(_comboDisplay);

    _playerHealth = PlayerHealth();
    add(_playerHealth);
  }

  Future<void> _createPlayer() async {
    player = Player()
      ..anchor = Anchor.center
      ..position = Vector2(size.x / 2, size.y * 0.8)
      ..priority = 2;
    add(player);
  }

  Future<void> _createJoystick() async {
    joystick = JoystickComponent(
      knob: SpriteComponent(
        sprite: await loadSprite('joystick_knob.png'),
        size: Vector2.all(50),
      ),
      background: SpriteComponent(
        sprite: await loadSprite('joystick_background.png'),
        size: Vector2.all(100),
      ),
      anchor: Anchor.bottomLeft,
      position: Vector2(20, size.y - 20),
      priority: 10,
    );
    add(joystick);
  }

  void _createShootButton() {
    _shootButton = ShootButton()
      ..anchor = Anchor.bottomRight
      ..position = Vector2(size.x - 20, size.y - 20)
      ..priority = 10;
    add(_shootButton);
  }

  void _createPickupSpawner() {
    _pickupSpawner = SpawnComponent.periodRange(
      factory: (index) => Pickup(
        position: generateSpawnPosition(),
        pickupType:
            PickupType.values[_random.nextInt(PickupType.values.length)],
      ),
      minPeriod: 5.0,
      maxPeriod: 10.0,
      selfPositioning: true,
    );
    add(_pickupSpawner);
  }

  Vector2 generateSpawnPosition() {
    return Vector2(
      _random.nextDouble() * (size.x - 100) + 50,
      -100,
    );
  }

  void incrementScore(int amount) {
    _combo++;
    int bonus = 0;
    if (_combo > 5) bonus = _combo * 2;

    _score += amount + bonus;
    _scoreDisplay.text = _score.toString();

    if (_combo > 1) {
      _comboDisplay.text = 'COMBO x$_combo';
    } else {
      _comboDisplay.text = '';
    }

    final popEffect = ScaleEffect.to(
      Vector2.all(1.2),
      EffectController(duration: 0.1, alternate: true),
    );
    _scoreDisplay.add(popEffect);
  }

  void resetCombo() {
    _combo = 0;
    _comboDisplay.text = '';
  }

  void showFloatingText(String text, Vector2 position,
      {Color color = Colors.white}) {
    final textComponent = TextComponent(
      text: text,
      position: position,
      anchor: Anchor.center,
      priority: 15,
      textRenderer: TextPaint(
        style: TextStyle(
            color: color, fontSize: 24, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 10, color: color)]),
      ),
    );
    add(textComponent);

    // Simplified effect: Float up, then remove. No opacity fade.
    textComponent.add(
      SequenceEffect([
        MoveByEffect(Vector2(0, -50),
            EffectController(duration: 1.5, curve: Curves.easeOut)),
        RemoveEffect(),
      ]),
    );
  }

  void showDamageText(String text, Vector2 position, Color color) {
    final textComponent = TextComponent(
      text: text,
      position: position,
      anchor: Anchor.center,
      priority: 15,
      textRenderer: TextPaint(
        style: TextStyle(
            color: color, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
    add(textComponent);

    // Simplified effect: Float up quickly, then remove. No opacity fade.
    textComponent.add(
      SequenceEffect([
        MoveByEffect(
          Vector2(0, -30),
          EffectController(duration: 0.5, curve: Curves.easeOut)
        ),
        RemoveEffect(),
      ]),
    );
  }

  void triggerScreenFlash() {
    // Manual flash without using OpacityEffect to avoid crash
    _flashScreen.paint.color = Colors.red.withOpacity(0.5);

    // Turn it off after 100ms
    add(TimerComponent(
      period: 0.1,
      removeOnFinish: true,
      onTick: () {
        _flashScreen.paint.color = Colors.red.withOpacity(0.0);
      }
    ));
  }

  void togglePause() {
    if (paused) {
      resumeEngine();
      overlays.remove('PauseMenu');
    } else {
      pauseEngine();
      overlays.add('PauseMenu');
    }
  }

  void onPlayerHit() {
    _playerHealth.updateHealth(player.health);
    triggerScreenFlash();
    resetCombo();
  }

  void playerDied() {
    if (overlays.isActive('GameOver')) return;
    HighScoreManager.saveHighScore(_score);
    overlays.add('GameOver');
    pauseEngine();
  }

  void restartGame() {
    children.whereType<PositionComponent>().forEach((component) {
      if (component is! ParallaxBackground && component is! AudioManager) {
        remove(component);
      }
    });
    if (children.contains(_flashScreen)) remove(_flashScreen);

    startGame();
    resumeEngine();
  }

  void quitGame() {
    children.whereType<PositionComponent>().forEach((component) {
      if (component is! ParallaxBackground && component is! AudioManager) {
        remove(component);
      }
    });

    overlays.add('Title');
    resumeEngine();
  }

  void shakeScreen() {
    camera.viewfinder.add(
      MoveByEffect(
        Vector2(8, 8),
        EffectController(duration: 0.07, alternate: true, repeatCount: 2),
      ),
    );
  }
}