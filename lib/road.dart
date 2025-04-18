import 'package:flame/components.dart';

class Road extends SpriteComponent {
  double speed = 100; // pixels per second

  Road({
    required Sprite sprite,
    required Vector2 size,
    required Vector2 position,
  }) : super(sprite: sprite, size: size, position: position);

  @override
  void update(double dt) {
    super.update(dt);
    y += speed * dt;

    // reset position when it goes off-screen
    if (y >= size.y) {
      y = -size.y + (y - size.y);
    }
  }
}
