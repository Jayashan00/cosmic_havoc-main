// lib/components/wave_manager.dart
import 'dart:math';
import 'package:flutter/material.dart'; // ++ THIS LINE IS THE FIX ++

import 'package:flame/components.dart';
import 'package:cosmic_havoc/my_game.dart';
import 'package:cosmic_havoc/components/enemy.dart';
import 'package:cosmic_havoc/components/asteroid.dart';
import 'package:cosmic_havoc/components/fighter_ship.dart';

class WaveManager extends Component with HasGameReference<MyGame> {
  int currentWave = 0;
  final Timer _waveTimer = Timer(5, repeat: false);
  final Random _random = Random();

  @override
  void onMount() {
    super.onMount();
    _waveTimer.start();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _waveTimer.update(dt);

    if (game.children.whereType<Asteroid>().isEmpty &&
        game.children.whereType<FighterShip>().isEmpty &&
        !_waveTimer.isRunning()) {

      // Grant wave clear bonus
      if (currentWave > 0) {
        game.incrementScore(100); // Give 100 points
        game.showFloatingText(
          "WAVE $currentWave CLEAR!",
          game.size / 2,
          color: Colors.yellow, // This line will now work
        );
      }

      currentWave++;
      spawnWave(currentWave);
      _waveTimer.start();
    }
  }

  void spawnWave(int waveNumber) {
    // Asteroids still spawn every wave
    int asteroidCount = 2 + waveNumber;
    for (int i = 0; i < asteroidCount; i++) {
      Future.delayed(Duration(milliseconds: _random.nextInt(5000) + 1000), () {
        if (game.isMounted && !game.paused) {
          game.add(Asteroid(position: game.generateSpawnPosition()));
        }
      });
    }

    // Start spawning fighters from wave 3 onwards, AND only on ODD waves
    if (waveNumber >= 3 && waveNumber % 2 != 0) {

      int fighterCount = (waveNumber / 2).floor();

      for (int i = 0; i < fighterCount; i++) {
        // Spawn them staggered throughout the wave
        Future.delayed(Duration(milliseconds: _random.nextInt(8000) + 3000), () {
          if (game.isMounted && !game.paused) {
            game.add(FighterShip(position: game.generateSpawnPosition()));
          }
        });
      }
    }
  }
}