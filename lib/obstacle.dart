import 'package:flame/components.dart';
import 'obstacle_type.dart';

class Obstacle extends SpriteComponent {
  final ObstacleType type;

  Obstacle({
    required this.type,
    required Sprite sprite,
    required Vector2 size,
    required Vector2 position,
  }) : super(sprite: sprite, size: size, position: position);

  @override
  void update(double dt) {
    super.update(dt);
    position.y += 200 * dt;
  }
}