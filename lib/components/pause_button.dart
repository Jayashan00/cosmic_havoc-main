import 'dart:async';
import 'package:cosmic_havoc/my_game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart'; // For Icons

class PauseButton extends PositionComponent with HasGameReference<MyGame>, TapCallbacks {

  PauseButton() : super(size: Vector2.all(50), anchor: Anchor.topLeft);

  @override
  FutureOr<void> onLoad() async {
    // We will draw a simple pause icon using rendering since we don't have an image
    position = Vector2(20, 50); // Top left, below score
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.white.withOpacity(0.8);
    // Draw two vertical bars (Pause symbol)
    canvas.drawRect(const Rect.fromLTWH(10, 10, 10, 30), paint);
    canvas.drawRect(const Rect.fromLTWH(30, 10, 10, 30), paint);
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.togglePause();
  }
}