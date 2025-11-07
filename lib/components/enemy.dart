// lib/components/enemy.dart

import 'package:flame/collisions.dart'; // <-- ADD THIS
import 'package:flame/components.dart';
import 'package:cosmic_havoc/components/laser.dart'; // <-- ADD THIS
import 'package:cosmic_havoc/my_game.dart';

// An abstract base class for all enemy types
abstract class Enemy extends SpriteAnimationComponent
    with HasGameReference<MyGame>, CollisionCallbacks { // This line is now correct
  double health;
  double speed;
  int scoreValue;

  Enemy({
    required this.health,
    required this.speed,
    required this.scoreValue,
    super.position,
    super.size,
  }) : super(anchor: Anchor.center);

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
    // Default movement: move down the screen
    position.y += speed * dt;

    // Remove if off-screen
    if (position.y > game.size.y + size.y) {
      removeFromParent();
    }
  }

  @override // The override is now valid
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Laser) { // 'Laser' is now a known type
      takeDamage(1);
      other.removeFromParent();
    }
  }
}