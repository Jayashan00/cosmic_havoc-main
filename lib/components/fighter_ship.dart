// lib/components/fighter_ship.dart
import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import '../my_game.dart';
import 'laser.dart';

// Now extends SpriteComponent directly to fix the 'sprite' error
class FighterShip extends SpriteComponent
    with HasGameReference<MyGame>, CollisionCallbacks {

  final Random _random = Random();
  late Timer _laserTimer;
  double health = 2;
  final double speed = 100;
  final int scoreValue = 5;

  FighterShip({required super.position})
      : super(
          // The size is now removed from here, it will be set by the sprite
        );

  @override
  Future<void> onLoad() async {
    // This now works because the class is a SpriteComponent
    sprite = await game.loadSprite('fighter_ship.png');
    // Set the size after the sprite is loaded
    size = sprite!.originalSize * 0.5; // You can adjust the 0.5 scale factor
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
    }
  }

  void takeDamage(double damage) {
    health -= damage;
    if (health <= 0) {
      die();
    }
  }

  void die() {
    game.incrementScore(scoreValue);
    // TODO: Add explosion effect
    removeFromParent();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _laserTimer.update(dt);

    // Also move down the screen slowly
    position.y += speed * dt;
    if (position.y > game.size.y) {
      removeFromParent();
    }
  }

  void _fireLaser() {
    // This check is now corrected to use 'game.paused'
    if (game.paused || !isMounted) return;

    final laser = Laser(
      position: position + Vector2(0, size.y / 2),
      laserType: LaserType.enemy,
    );
    parent?.add(laser);
  }

  @override
  void onRemove() {
    super.onRemove();
    _laserTimer.stop();
  }
}