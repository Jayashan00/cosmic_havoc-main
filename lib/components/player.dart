// lib/components/player.dart
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:cosmic_havoc/components/asteroid.dart';
import 'package:cosmic_havoc/components/bomb.dart';
import 'package:cosmic_havoc/components/enemy.dart';
import 'package:cosmic_havoc/components/explosion.dart';
import 'package:cosmic_havoc/components/laser.dart';
import 'package:cosmic_havoc/components/pickup.dart';
import 'package:cosmic_havoc/components/shield.dart';
import 'package:cosmic_havoc/my_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/services.dart';

class Player extends SpriteAnimationComponent
    with HasGameReference<MyGame>, KeyboardHandler, CollisionCallbacks {
  bool _isShooting = false;
  final double _fireCooldown = 0.2;
  double _elapsedFireTime = 0.0;
  final Vector2 _keyboardMovement = Vector2.zero();
  bool _isDestroyed = false;
  final Random _random = Random();
  late Timer _explosionTimer;
  late Timer _laserPowerupTimer;
  late Timer _invulnerabilityTimer;
  bool _isInvulnerable = false;
  Shield? activeShield;
  late String _color;

  double health = 3;

  Player() {
    _explosionTimer =
        Timer(0.1, onTick: _createRandomExplosion, repeat: true, autoStart: false);
    _laserPowerupTimer = Timer(10.0, autoStart: false);
    _invulnerabilityTimer =
        Timer(1.5, onTick: () => _isInvulnerable = false, autoStart: false);
  }

  @override
  FutureOr<void> onLoad() async {
    _color = game.playerColors[game.playerColorIndex];
    animation = await _loadAnimation();
    size *= 0.3;
    add(RectangleHitbox.relative(Vector2(0.6, 0.9),
        parentSize: size, anchor: Anchor.center));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isDestroyed) {
      _explosionTimer.update(dt);
      return;
    }
    _invulnerabilityTimer.update(dt);
    _laserPowerupTimer.update(dt);

    final Vector2 movement = game.joystick.relativeDelta + _keyboardMovement;
    position += movement.normalized() * 300 * dt; // Increased speed slightly

    _handleScreenBounds();

    _elapsedFireTime += dt;
    if (_isShooting && _elapsedFireTime >= _fireCooldown) {
      _fireLaser();
      _elapsedFireTime = 0.0;
    }
  }

  void takeHit() {
    if (_isInvulnerable || activeShield != null || _isDestroyed) return;

    game.shakeScreen();
    health--;
    game.onPlayerHit();

    _isInvulnerable = true;
    _invulnerabilityTimer.start();
    add(
      OpacityEffect.to(
          0.5, EffectController(duration: 0.1, alternate: true, repeatCount: 7)),
    );

    if (health <= 0) {
      _handleDestruction();
    }
  }

  void _handleDestruction() async {
    // ... inside _handleDestruction method
    if (_isDestroyed) return;
    _isDestroyed = true;

    // This is the correct way to disable collisions
    remove(children.whereType<RectangleHitbox>().first);

    _explosionTimer.start();
    // ...
    animation = SpriteAnimation.spriteList(
        [await game.loadSprite('player_${_color}_off.png')],
        stepTime: double.infinity);

    add(OpacityEffect.fadeOut(EffectController(duration: 3.0),
        onComplete: () => _explosionTimer.stop()));
    add(MoveEffect.by(Vector2(0, 200), EffectController(duration: 3.0)));
    add(RemoveEffect(delay: 4.0, onComplete: game.playerDied));
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (_isDestroyed) return;

    if (other is Asteroid || other is Enemy) {
      takeHit();
    } else if (other is Laser && other.laserType == LaserType.enemy) {
      other.removeFromParent();
      takeHit();
    } else if (other is Pickup) {
      game.audioManager.playSound('collect');
      other.removeFromParent();
      game.incrementScore(1);
      switch (other.pickupType) {
        case PickupType.laser:
          _laserPowerupTimer.start();
          break;
        case PickupType.bomb:
          game.add(Bomb(position: position.clone()));
          break;
        case PickupType.shield:
          if (activeShield != null) remove(activeShield!);
          activeShield = Shield();
          add(activeShield!);
          break;
      }
    }
  }

  Future<SpriteAnimation> _loadAnimation() async {
    return SpriteAnimation.spriteList([
      await game.loadSprite('player_${_color}_on0.png'),
      await game.loadSprite('player_${_color}_on1.png'),
    ], stepTime: 0.1, loop: true);
  }

  void _handleScreenBounds() {
    final double screenWidth = game.size.x;
    final double screenHeight = game.size.y;
    position.y =
        clampDouble(position.y, size.y / 2, screenHeight - size.y / 2);
    if (position.x < 0) {
      position.x = screenWidth;
    } else if (position.x > screenWidth) {
      position.x = 0;
    }
  }

  void startShooting() => _isShooting = true;
  void stopShooting() => _isShooting = false;

  void _fireLaser() {
    game.audioManager.playSound('laser');
    game.add(Laser(
        position: position.clone() + Vector2(0, -size.y / 2),
        laserType: LaserType.player));
    if (_laserPowerupTimer.isRunning()) {
      game.add(Laser(
          position: position.clone() + Vector2(0, -size.y / 2),
          angle: 15 * degrees2Radians,
          laserType: LaserType.player));
      game.add(Laser(
          position: position.clone() + Vector2(0, -size.y / 2),
          angle: -15 * degrees2Radians,
          laserType: LaserType.player));
    }
  }

  void _createRandomExplosion() {
    final Vector2 explosionPosition = Vector2(
        position.x - size.x / 2 + _random.nextDouble() * size.x,
        position.y - size.y / 2 + _random.nextDouble() * size.y);
    final ExplosionType explosionType =
        _random.nextBool() ? ExplosionType.smoke : ExplosionType.fire;
    final Explosion explosion = Explosion(
        position: explosionPosition,
        explosionSize: size.x * 0.7,
        explosionType: explosionType);
    game.add(explosion);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _keyboardMovement.x = 0;
    _keyboardMovement.x +=
        keysPressed.contains(LogicalKeyboardKey.arrowLeft) ? -1 : 0;
    _keyboardMovement.x +=
        keysPressed.contains(LogicalKeyboardKey.arrowRight) ? 1 : 0;
    _keyboardMovement.y = 0;
    _keyboardMovement.y +=
        keysPressed.contains(LogicalKeyboardKey.arrowUp) ? -1 : 0;
    _keyboardMovement.y +=
        keysPressed.contains(LogicalKeyboardKey.arrowDown) ? 1 : 0;
    return true;
  }
}