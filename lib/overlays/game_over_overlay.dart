// lib/overlays/game_over_overlay.dart
import 'package:cosmic_havoc/my_game.dart';
import 'package:cosmic_havoc/utils/highscore_manager.dart';
import 'package:flutter/material.dart';

class GameOverOverlay extends StatefulWidget {
  final MyGame game;
  const GameOverOverlay({super.key, required this.game});

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay> {
  int _highScore = 0;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final score = await HighScoreManager.getHighScore();
    if (mounted) {
      setState(() {
        _highScore = score;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withAlpha(150),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('GAME OVER',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // ++ ADDED ++
            // Display the score from the run that just ended
            Text('Your Score: ${widget.game.score}',
                style: const TextStyle(color: Colors.white, fontSize: 24)),

            const SizedBox(height: 20),

            // ++ MODIFIED ++
            // Now correctly shows the all-time high score
            Text('High Score: $_highScore',
                style: const TextStyle(color: Colors.white, fontSize: 24)),

            const SizedBox(height: 30),
            _buildButton('PLAY AGAIN', () => widget.game.restartGame()),
            const SizedBox(height: 15),
            _buildButton('QUIT GAME', () => widget.game.quitGame()),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed) {
    return TextButton(
      onPressed: () {
        widget.game.audioManager.playSound('click');
        onPressed();
        if (mounted) {
          widget.game.overlays.remove('GameOver');
        }
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 28)),
    );
  }
}