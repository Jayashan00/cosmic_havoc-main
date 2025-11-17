// lib/components/laser.dart
import 'dart:async';
import 'dart:math';

import 'package:cosmic_havoc/components/asteroid.dart';
import 'package:cosmic_havoc/components/enemy.dart';
import 'package:cosmic_havoc/components/fighter_ship.dart'; // ++ ADDED ++
import 'package:cosmic_havoc/components/player.dart';
import 'package:cosmic_havoc/my_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

enum LaserType { player, enemy }

class Laser extends SpriteComponent
    with HasGameReference<MyGame>, CollisionCallbacks {
  final LaserType laserType;
  final double _speed = 500;

  Laser({
    required super.position,
    super.angle = 0.0,
    required this.laserType,
  }) : super(
          anchor: Anchor.center,
          // ++ MODIFIED ++
          // Priority 1 to be above the background
          priority: 1,
        );

  @override
  FutureOr<void> onLoad() async {
    sprite = await game.loadSprite(
      laserType == LaserType.player ? 'laser.png' : 'laser_red.png',
    );
    size *= 0.25;
    add(RectangleHitbox());
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    double direction = laserType == LaserType.player ? -1 : 1;
    position += Vector2(sin(angle), cos(angle) * direction) * _speed * dt;

    // remove the laser if it goes off screen
    if (position.y < -size.y / 2 || position.y > game.size.y + size.y / 2) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    // ++ MODIFIED ++
    // Added check for FighterShip
    if (laserType == LaserType.player &&
        (other is Asteroid || other is Enemy || other is FighterShip)) {
      removeFromParent();
      // The onCollisionStart in Asteroid/Enemy/FighterShip will handle taking damage
    } else if (laserType == LaserType.enemy && other is Player) {
      // The onCollision in Player will handle taking damage
      // (The laser is removed in the Player's onCollisionStart)
    }
  }
}