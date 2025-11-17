// lib/components/fighter_ship.dart
import 'dart:math';
import 'package:cosmic_havoc/components/explosion.dart'; // ++ ADDED ++
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
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
          // ++ ADDED ++
          // Set priority to 1 to draw above the background
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
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Laser && other.laserType == LaserType.player) {
      takeDamage(1);
      // ++ ADDED ++
      // Ensure the laser is removed on hit
      other.removeFromParent();
    }
  }

  void takeDamage(double damage) {
    health -= damage;
    if (health <= 0) {
      die();
    }
  }

  // ++ MODIFIED ++
  // Added explosion effect
  void die() {
    game.incrementScore(scoreValue);

    // Create an explosion
    final Explosion explosion = Explosion(
      position: position.clone(),
      explosionSize: size.x * 1.2, // Make it a bit bigger than the ship
      explosionType: ExplosionType.fire, // Fire explosion for enemies
    );
    game.add(explosion);

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

  // ++ MODIFIED ++
  // Added sound effect
  void _fireLaser() {
    if (game.paused || !isMounted) return;

    // ++ ADDED ++
    game.audioManager.playSound('fire');

    final laser = Laser(
      position: position + Vector2(0, size.y / 2),
      laserType: LaserType.enemy,
    );
    // Use game.add to ensure it has the correct parent
    game.add(laser);
  }

  @override
  void onRemove() {
    super.onRemove();
    _laserTimer.stop();
  }
}