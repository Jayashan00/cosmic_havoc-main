// lib/components/player_health.dart
import 'package:flame/components.dart';
import '../my_game.dart';

class PlayerHealth extends PositionComponent with HasGameReference<MyGame> {
  late final Sprite heartSprite;
  // late final Sprite heartHalfSprite; // <-- REMOVED
  final List<SpriteComponent> _hearts = [];

  PlayerHealth() : super(position: Vector2(20, 20), priority: 11);

  @override
  Future<void> onLoad() async {
    heartSprite = await game.loadSprite('heart.png');
    // heartHalfSprite = await game.loadSprite('heart_half.png'); // <-- REMOVED
    updateHealth(game.player.health);
  }

  // ++ THIS IS THE FIX for "heart_half.png" not found ++
  // This logic only uses full hearts.
  void updateHealth(double health) {
    removeAll(_hearts);
    _hearts.clear();

    for (int i = 0; i < health.floor(); i++) {
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