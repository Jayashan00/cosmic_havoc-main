// lib/components/fighter_ship.dart
import 'dart:math';
<<<<<<< HEAD
import 'package:cosmic_havoc/components/explosion.dart'; // ++ ADDED ++
=======
>>>>>>> 9af76411c8d8ea673107c35d8fea354f8d753e1d
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import '../my_game.dart';
import 'laser.dart';

<<<<<<< HEAD
class FighterShip extends SpriteComponent
    with HasGameReference<MyGame>, CollisionCallbacks {
=======
// Now extends SpriteComponent directly to fix the 'sprite' error
class FighterShip extends SpriteComponent
    with HasGameReference<MyGame>, CollisionCallbacks {

>>>>>>> 9af76411c8d8ea673107c35d8fea354f8d753e1d
  final Random _random = Random();
  late Timer _laserTimer;
  double health = 2;
  final double speed = 100;
  final int scoreValue = 5;

  FighterShip({required super.position})
      : super(
<<<<<<< HEAD
          // ++ ADDED ++
          // Set priority to 1 to draw above the background
          priority: 1,
=======
          // The size is now removed from here, it will be set by the sprite
>>>>>>> 9af76411c8d8ea673107c35d8fea354f8d753e1d
        );

  @override
  Future<void> onLoad() async {
<<<<<<< HEAD
    sprite = await game.loadSprite('fighter_ship.png');
    size = sprite!.originalSize * 0.5;
=======
    // This now works because the class is a SpriteComponent
    sprite = await game.loadSprite('fighter_ship.png');
    // Set the size after the sprite is loaded
    size = sprite!.originalSize * 0.5; // You can adjust the 0.5 scale factor
>>>>>>> 9af76411c8d8ea673107c35d8fea354f8d753e1d
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
<<<<<<< HEAD
      // ++ ADDED ++
      // Ensure the laser is removed on hit
      other.removeFromParent();
=======
>>>>>>> 9af76411c8d8ea673107c35d8fea354f8d753e1d
    }
  }

  void takeDamage(double damage) {
    health -= damage;
    if (health <= 0) {
      die();
    }
  }

<<<<<<< HEAD
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

=======
  void die() {
    game.incrementScore(scoreValue);
    // TODO: Add explosion effect
>>>>>>> 9af76411c8d8ea673107c35d8fea354f8d753e1d
    removeFromParent();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _laserTimer.update(dt);

<<<<<<< HEAD
=======
    // Also move down the screen slowly
>>>>>>> 9af76411c8d8ea673107c35d8fea354f8d753e1d
    position.y += speed * dt;
    if (position.y > game.size.y) {
      removeFromParent();
    }
  }

<<<<<<< HEAD
  // ++ MODIFIED ++
  // Added sound effect
  void _fireLaser() {
    if (game.paused || !isMounted) return;

    // ++ ADDED ++
    game.audioManager.playSound('fire');

=======
  void _fireLaser() {
    // This check is now corrected to use 'game.paused'
    if (game.paused || !isMounted) return;

>>>>>>> 9af76411c8d8ea673107c35d8fea354f8d753e1d
    final laser = Laser(
      position: position + Vector2(0, size.y / 2),
      laserType: LaserType.enemy,
    );
<<<<<<< HEAD
    // Use game.add to ensure it has the correct parent
    game.add(laser);
=======
    parent?.add(laser);
>>>>>>> 9af76411c8d8ea673107c35d8fea354f8d753e1d
  }

  @override
  void onRemove() {
    super.onRemove();
    _laserTimer.stop();
  }
}