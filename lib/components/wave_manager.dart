// lib/components/wave_manager.dart
<<<<<<< HEAD
import 'dart:math';
import 'package:flutter/material.dart'; // ++ THIS LINE IS THE FIX ++

=======
>>>>>>> 9af76411c8d8ea673107c35d8fea354f8d753e1d
import 'package:flame/components.dart';
import 'package:cosmic_havoc/my_game.dart';
import 'package:cosmic_havoc/components/enemy.dart';
import 'package:cosmic_havoc/components/asteroid.dart';
import 'package:cosmic_havoc/components/fighter_ship.dart';

class WaveManager extends Component with HasGameReference<MyGame> {
  int currentWave = 0;
  final Timer _waveTimer = Timer(5, repeat: false);
<<<<<<< HEAD
  final Random _random = Random();
=======
>>>>>>> 9af76411c8d8ea673107c35d8fea354f8d753e1d

  @override
  void onMount() {
    super.onMount();
    _waveTimer.start();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _waveTimer.update(dt);

<<<<<<< HEAD
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

=======
    if (game.children.whereType<Enemy>().isEmpty &&
        game.children.whereType<Asteroid>().isEmpty &&
        !_waveTimer.isRunning()) {
>>>>>>> 9af76411c8d8ea673107c35d8fea354f8d753e1d
      currentWave++;
      spawnWave(currentWave);
      _waveTimer.start();
    }
  }

  void spawnWave(int waveNumber) {
<<<<<<< HEAD
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
=======
    int asteroidCount = 2 + waveNumber;
    for (int i = 0; i < asteroidCount; i++) {
      game.add(Asteroid(position: game.generateSpawnPosition()));
    }

    // Start spawning fighters from wave 2 onwards
    if (waveNumber >= 2) {
      int fighterCount = waveNumber - 1;
      for (int i = 0; i < fighterCount; i++) {
        game.add(FighterShip(position: game.generateSpawnPosition()));
>>>>>>> 9af76411c8d8ea673107c35d8fea354f8d753e1d
      }
    }
  }
}