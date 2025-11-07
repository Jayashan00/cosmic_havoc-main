// components/parallax_background.dart
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:cosmic_havoc/my_game.dart';

class ParallaxBackground extends ParallaxComponent<MyGame> {
  @override
  Future<void> onLoad() async {
    parallax = await game.loadParallax(
      [
        ParallaxImageData('bg_layer1.png'), // Slowest
        ParallaxImageData('bg_layer2.png'),
        ParallaxImageData('bg_layer3.png'), // Fastest
      ],
      baseVelocity: Vector2(0, 20),      // Base speed of the parallax
      velocityMultiplierDelta: Vector2(0, 1.5), // How much speed increases per layer
    );
  }
}