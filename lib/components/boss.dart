import 'dart:math';
import 'package:cosmic_havoc/components/engine_trail.dart';
import 'package:cosmic_havoc/components/explosion.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart'; // Needed for Colors
import '../my_game.dart';
import 'laser.dart';

class Boss extends SpriteComponent
    with HasGameReference<MyGame>, CollisionCallbacks {
  final Random _random = Random();
  late Timer _laserTimer;
  double health = 50; // Lots of health
  final double speed = 40; // Slower movement
  final int scoreValue = 500;
  bool _movingRight = true;

  Boss({required super.position})
      : super(
          priority: 1,
        );

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite('fighter_ship.png');
    // Scale up to be a BOSS
    size = sprite!.originalSize * 1.5;
    anchor = Anchor.center;

    // Tint it RED to look dangerous
    paint = Paint()..colorFilter = const ColorFilter.mode(Colors.red, BlendMode.srcATop);

    add(RectangleHitbox());

    // Add Engine Trail
    parent?.add(EngineTrail(parent: this, isEnemy: true, isBoss: true));

    // Fire faster than normal enemies
    _laserTimer = Timer(0.8, onTick: _fireLaser, repeat: true);
    _laserTimer.start();

    // Move down initially
    add(MoveByEffect(Vector2(0, 100), EffectController(duration: 2)));
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Laser && other.laserType == LaserType.player) {
      takeDamage(1);
      other.removeFromParent();
    }
  }

  void takeDamage(double damage) {
    health -= damage;
    // Flash white when hit
    add(ColorEffect(Colors.white, EffectController(duration: 0.1, alternate: true)));

    // Show damage number
    game.showDamageText(damage.toInt().toString(), position.clone(), Colors.white);

    if (health <= 0) {
      die();
    }
  }

  void die() {
    game.incrementScore(scoreValue);

    // HUGE explosion
    final Explosion explosion = Explosion(
      position: position.clone(),
      explosionSize: size.x * 2,
      explosionType: ExplosionType.fire,
    );
    game.add(explosion);

    removeFromParent();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _laserTimer.update(dt);

    // Boss Logic: Move side to side
    if (_movingRight) {
      position.x += speed * dt;
      if (position.x > game.size.x - size.x/2) _movingRight = false;
    } else {
      position.x -= speed * dt;
      if (position.x < size.x/2) _movingRight = true;
    }
  }

  void _fireLaser() {
    if (game.paused || !isMounted) return;
    game.audioManager.playSound('fire');

    // Dual lasers for boss
    game.add(Laser(position: position + Vector2(-20, size.y/2), laserType: LaserType.enemy));
    game.add(Laser(position: position + Vector2(20, size.y/2), laserType: LaserType.enemy));
  }

  @override
  void onRemove() {
    super.onRemove();
    _laserTimer.stop();
  }
}