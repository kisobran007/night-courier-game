import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'delivery_game.dart';

void main() {
  runApp(
    GameWidget(
      game: DeliveryGame(),
    ),
  );
}