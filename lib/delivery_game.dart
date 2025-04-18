import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'road.dart';
import 'delivery_bike.dart';
import 'obstacle.dart';
import 'obstacle_type.dart';
import 'game_manager.dart';
import 'pickup_item.dart';
import 'pickup_type.dart';

class DeliveryGame extends FlameGame with TapDetector {
  late Road road1;
  late Road road2;
  late DeliveryBike bike;
  late List<Sprite> obstacleSprites;
  final int totalLanes = 3;
  late double laneWidth;
  int currentLane = 1;
  late List<double> lanePositions;
  double spawnTimer = 0.0;
  final Random random = Random();
  int? lastObstacleLane;
  final List<Obstacle> activeObstacles = [];
  late GameManager gameManager;
  TextComponent? gameOverText;
  late TextComponent scoreText;
  int score = 0;
  double scoreTimer = 0;
  final List<PickupItem> activePickups = [];
  double pickupSpawnTimer = 0.0;
  late RectangleComponent fuelBarBackground;
  late RectangleComponent fuelBarFill;


  @override
  Future<void> onLoad() async {
    final roadSprite = await loadSprite('road.png');
    final bikeSprite = await loadSprite('delivery_bike.png');
    obstacleSprites = [
      await loadSprite('obstacle_car.png'),
      await loadSprite('obstacle_cones.png'),
      await loadSprite('obstacle_manhole.png'),
    ];

    laneWidth = size.x / totalLanes;

    road1 = Road(sprite: roadSprite, size: size, position: Vector2(0, 0));
    road2 = Road(sprite: roadSprite, size: size, position: Vector2(0, -size.y));

    add(road1);
    add(road2);

    bike = DeliveryBike(
      sprite: bikeSprite,
      size: Vector2(200, 200),
      position: Vector2(laneX(currentLane), size.y - 200),
    );

    add(bike);

    gameManager = GameManager();
    add(gameManager);

    lanePositions = List.generate(
      totalLanes,
      (index) => laneX(index),
    );

    scoreText = TextComponent(
      text: 'Score: 0',
      position: Vector2(size.x / 2, 20),
      anchor: Anchor.topCenter,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(scoreText);

    final fuelLabel = TextComponent(
      text: 'Fuel',
      position: Vector2(20, 0),
      anchor: Anchor.topLeft,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(fuelLabel);

    // Fuel Bar Background
    fuelBarBackground = RectangleComponent(
      size: Vector2(200, 20),
      position: Vector2(20, 20),
      paint: Paint()..color = Colors.grey,
    );
    add(fuelBarBackground);

    // Fuel Bar Fill
    fuelBarFill = RectangleComponent(
      size: Vector2(200, 20),
      position: Vector2(20, 20),
      paint: Paint()..color = Colors.green,
    );
    add(fuelBarFill);
  }

  double laneX(int lane) {
    return lane * laneWidth + laneWidth / 2 - 40;
  }

  @override
  void onTapDown(TapDownInfo info) {
    if (gameManager.isGameOver) {
      restartGame();
      return;
    }

    final touchX = info.eventPosition.global.x;

    if (touchX < size.x / 2 && currentLane > 0) {
      currentLane--;
      tiltBikeLeft();
    } else if (touchX >= size.x / 2 && currentLane < totalLanes - 1) {
      currentLane++;
      tiltBikeRight();
    }
  }


  @override
  void update(double dt) {
    super.update(dt);

    // Update fuel bar width i boju
    final fuelRatio = gameManager.fuel / 100;
    fuelBarFill.size.x = 200 * fuelRatio;

    // Boja prelazi iz zelene ka crvenoj
    fuelBarFill.paint.color = Color.lerp(Colors.red, Colors.green, fuelRatio)!;

    if (!gameManager.isGameOver) {
      gameManager.consumeFuel(dt * 5);

      if (gameManager.fuel <= 0) {
        gameManager.triggerGameOver();
        return;  // Game over ako gorivo nestane
      }

      // Kolizija sa preprekama
      for (final obstacle in activeObstacles.toList()) {
        if (bike.toRect().overlaps(obstacle.toRect())) {
          score -= obstacle.type.penalty;
          if (score < 0) score = 0;
          scoreText.text = 'Score: $score';
          obstacle.removeFromParent();
          activeObstacles.remove(obstacle);
        }
      }

      // Kolizija sa pickup item-ima
      for (final pickup in activePickups.toList()) {
        if (bike.toRect().overlaps(pickup.toRect())) {
          if (pickup.type == PickupType.fuel) {
            gameManager.refillFuel(30); // ili neka druga vrednost
          } else {
            score += pickup.type.scoreValue;
            scoreText.text = 'Score: $score';
          }

          pickup.removeFromParent();
          activePickups.remove(pickup);
        }
      }

      // Spawn prepreka
      spawnTimer += dt;
      activeObstacles.removeWhere((o) => o.position.y > size.y);

      if (spawnTimer > 1.5 && activeObstacles.length < 2) {
        final availableLanes = List<int>.generate(totalLanes, (index) => index);
        if (lastObstacleLane != null) {
          availableLanes.remove(lastObstacleLane);
        }

        final laneIndex = availableLanes[random.nextInt(availableLanes.length)];
        lastObstacleLane = laneIndex;

        final spriteIndex = random.nextInt(obstacleSprites.length);
        final randomSprite = obstacleSprites[spriteIndex];
        final obstacleType = ObstacleType.values[spriteIndex];

        final obstacle = Obstacle(
          type: obstacleType,
          sprite: randomSprite,
          size: Vector2(200, 200),
          position: Vector2(laneX(laneIndex), -60),
        );

        add(obstacle);
        activeObstacles.add(obstacle);
        spawnTimer = 0;
      }

      // Spawn pickup item-a
      pickupSpawnTimer += dt;
      activePickups.removeWhere((p) => p.position.y > size.y);

      if (pickupSpawnTimer > 3.5 && activePickups.length < 2) {
        final laneIndex = random.nextInt(totalLanes);
        final type = PickupType.values[random.nextInt(PickupType.values.length)];
        spawnPickup(type, laneIndex);
      }
    }

    if (gameManager.isGameOver) {
      if (gameOverText == null) {
        gameOverText = TextComponent(
          text: 'Game Over\nScore: $score\nTap to Restart',
          anchor: Anchor.center,
          position: size / 2,
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
        add(gameOverText!);
      }
    }
  }


  void spawnPickup(PickupType type, int laneIndex) async {
    final pickup = await PickupItem.create(type, Vector2(laneX(laneIndex), -60));
    add(pickup);
    activePickups.add(pickup);
  }

  void restartGame() {
    gameManager.reset();

    score = 0;
    scoreText.text = 'Score: 0';
    
    currentLane = 1;
    bike.position = Vector2(laneX(currentLane), size.y - 200);
    
    // Resetuj sve efekte sa bike
    bike.clearEffects();

    // Resetuj prepreke
    final obstacles = children.whereType<Obstacle>().toList();
    for (final obstacle in obstacles) {
      obstacle.removeFromParent();
    }
    activeObstacles.clear();
    
    // Resetuj pickupe
    for (final pickup in activePickups) {
      pickup.removeFromParent();
    }
    activePickups.clear();
    
    spawnTimer = 0;
    pickupSpawnTimer = 0;

    // Ukloni Game Over tekst ako je prisutan
    if (gameOverText != null) {
      gameOverText!.removeFromParent();
      gameOverText = null;
    }

    // Ponovo dodaj bike i road
    add(bike);
  }

void tiltBike(double angle) {
  final newX = laneX(currentLane);

  // Clear any previous effects
  bike.clearEffects();

  // Move left/right
  bike.add(
    MoveEffect.to(
      Vector2(newX, bike.position.y),
      EffectController(duration: 0.3, curve: Curves.easeOut),
    ),
  );

  // Bounce up/down
  bike.add(
    MoveEffect.by(
      Vector2(0, -10),
      EffectController(
        duration: 0.15,
        reverseDuration: 0.15,
        curve: Curves.easeOut,
        repeatCount: 1,
        alternate: true,
      ),
    ),
  );

  // Tilt (rotation)
  bike.angle = angle;
  add(TimerComponent(
    period: 0.2,
    removeOnFinish: true,
    onTick: () {
      bike.angle = 0;
    },
  ));
}

  void tiltBikeLeft() {
    tiltBike(-0.3);
  }

  void tiltBikeRight() {
    tiltBike(0.3);
  }
}