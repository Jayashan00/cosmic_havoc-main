// lib/components/player_health.dart
import 'package:flame/components.dart';
import '../my_game.dart';

class PlayerHealth extends PositionComponent with HasGameReference<MyGame> {
  late final Sprite heartSprite;
<<<<<<< HEAD
  // late final Sprite heartHalfSprite; // <-- REMOVED
=======
  late final Sprite heartHalfSprite;
>>>>>>> 9af76411c8d8ea673107c35d8fea354f8d753e1d
  final List<SpriteComponent> _hearts = [];

  PlayerHealth() : super(position: Vector2(20, 20), priority: 11);

<<<<<<< HEAD
  @override
  Future<void> onLoad() async {
    heartSprite = await game.loadSprite('heart.png');
    // heartHalfSprite = await game.loadSprite('heart_half.png'); // <-- REMOVED
    updateHealth(game.player.health);
  }

  // ++ THIS IS THE FIX for "heart_half.png" not found ++
  // This logic only uses full hearts.
=======
  // lib/components/player_health.dart
  @override
  Future<void> onLoad() async {
    heartSprite = await game.loadSprite('heart.png');
    updateHealth(game.player.health);
  }

>>>>>>> 9af76411c8d8ea673107c35d8fea354f8d753e1d
  void updateHealth(double health) {
    removeAll(_hearts);
    _hearts.clear();

<<<<<<< HEAD
    for (int i = 0; i < health.floor(); i++) {
=======
    for (int i = 0; i < health; i++) {
>>>>>>> 9af76411c8d8ea673107c35d8fea354f8d753e1d
      final heart = SpriteComponent(
        sprite: heartSprite,
        position: Vector2(i * 40, 0),
        size: Vector2.all(35),
      );
      _hearts.add(heart);
      add(heart);
    }
  }
}