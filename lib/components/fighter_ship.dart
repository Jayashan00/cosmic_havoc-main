import 'dart:math';
import 'package:cosmic_havoc/components/engine_trail.dart'; // ++ ADDED ++
import 'package:cosmic_havoc/components/explosion.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart'; // ++ ADDED for colors ++
import '../my_game.dart';
import 'laser.dart';

class FighterShip extends SpriteComponent
    with HasGameReference<MyGame>, CollisionCallbacks {
  final Random _random = Random();
  late Timer _laserTimer;
  double health = 2;
  final double speed = 100;
  final int scoreValue = 5;

  FighterShip({required super.position})
      : super(
          priority: 1,
        );

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite('fighter_ship.png');
    size = sprite!.originalSize * 0.5;
    anchor = Anchor.center;
    add(RectangleHitbox());

    _laserTimer =
        Timer(3 + _random.nextDouble() * 2, onTick: _fireLaser, repeat: true);
    _laserTimer.start();

    final double targetX =
        position.x < game.size.x / 2 ? game.size.x - 50 : 50;
    add(
      MoveToEffect(
        Vector2(targetX, position.y + 150),
        EffectController(duration: 4, alternate: true, infinite: true),
      ),
    );

    // ++ ADDED: Engine Trail ++
    parent?.add(EngineTrail(parent: this, isEnemy: true));
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
    // ++ ADDED: Damage Text ++
    game.showDamageText("1", position.clone(), Colors.orange);

    if (health <= 0) {
      die();
    }
  }

  void die() {
    game.incrementScore(scoreValue);

    final Explosion explosion = Explosion(
      position: position.clone(),
      explosionSize: size.x * 1.2,
      explosionType: ExplosionType.fire,
    );
    game.add(explosion);

    _fireLaser();

    removeFromParent();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _laserTimer.update(dt);

    position.y += speed * dt;
    if (position.y > game.size.y) {
      removeFromParent();
    }
  }

  void _fireLaser() {
    if (game.paused || !isMounted) return;

    game.audioManager.playSound('fire');

    final laser = Laser(
      position: position + Vector2(0, size.y / 2),
      laserType: LaserType.enemy,
    );
    game.add(laser);
  }

  @override
  void onRemove() {
    super.onRemove();
    _laserTimer.stop();
  }
}