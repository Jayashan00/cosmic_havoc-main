// lib/components/wave_manager.dart
import 'package:flame/components.dart';
import 'package:cosmic_havoc/my_game.dart';
import 'package:cosmic_havoc/components/enemy.dart';
import 'package:cosmic_havoc/components/asteroid.dart';
import 'package:cosmic_havoc/components/fighter_ship.dart';

class WaveManager extends Component with HasGameReference<MyGame> {
  int currentWave = 0;
  final Timer _waveTimer = Timer(5, repeat: false);

  @override
  void onMount() {
    super.onMount();
    _waveTimer.start();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _waveTimer.update(dt);

    if (game.children.whereType<Enemy>().isEmpty &&
        game.children.whereType<Asteroid>().isEmpty &&
        !_waveTimer.isRunning()) {
      currentWave++;
      spawnWave(currentWave);
      _waveTimer.start();
    }
  }

  void spawnWave(int waveNumber) {
    int asteroidCount = 2 + waveNumber;
    for (int i = 0; i < asteroidCount; i++) {
      game.add(Asteroid(position: game.generateSpawnPosition()));
    }

    // Start spawning fighters from wave 2 onwards
    if (waveNumber >= 2) {
      int fighterCount = waveNumber - 1;
      for (int i = 0; i < fighterCount; i++) {
        game.add(FighterShip(position: game.generateSpawnPosition()));
      }
    }
  }
}