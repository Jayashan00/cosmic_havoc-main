import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

class EngineTrail extends Component {
  final PositionComponent parent;
  final Random _random = Random();
  final bool isEnemy;
  final bool isBoss;

  EngineTrail({
    required this.parent,
    this.isEnemy = false,
    this.isBoss = false,
  });

  @override
  void update(double dt) {
    super.update(dt);

    if (parent.isMounted) {
      // Boss has a bigger trail
      double radius = isBoss ? 6.0 : (2.0 + _random.nextDouble() * 2);

      parent.parent?.add(
        ParticleSystemComponent(
          position: parent.position + Vector2(0, parent.size.y / 2 - 10),
          priority: 0, // Behind ships
          particle: Particle.generate(
            count: isBoss ? 4 : 2,
            lifespan: 0.4,
            generator: (i) => AcceleratedParticle(
              acceleration: Vector2(0, isEnemy ? -100 : 100),
              speed: Vector2(_random.nextDouble() * 20 - 10, isEnemy ? -50 : 100),
              child: CircleParticle(
                radius: radius,
                paint: Paint()
                  ..color = (isEnemy
                      ? (isBoss ? Colors.red : Colors.orange)
                      : Colors.cyan).withOpacity(0.6),
              ),
            ),
          ),
        ),
      );
    }
  }
}