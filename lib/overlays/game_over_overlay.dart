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
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'GAME OVER',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Arial',
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Score: ${widget.game.score}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'High Score: $_highScore',
                style: const TextStyle(
                  color: Colors.yellow,
                  fontSize: 24,
                  fontWeight: FontWeight.bold
                ),
              ),

              const SizedBox(height: 30),
              _buildButton('PLAY AGAIN', () => widget.game.restartGame()),
              const SizedBox(height: 15),
              _buildButton('QUIT GAME', () => widget.game.quitGame()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: 200,
      child: ElevatedButton(
        onPressed: () {
          widget.game.audioManager.playSound('click');
          onPressed();
          if (mounted) {
            widget.game.overlays.remove('GameOver');
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          elevation: 5,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
        ),
      ),
    );
  }
}