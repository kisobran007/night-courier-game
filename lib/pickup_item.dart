import 'package:flame/components.dart';
import 'pickup_type.dart'; // Ovde se nalazi enum i ekstenzija PickupTypeExtension

class PickupItem extends SpriteComponent {
  final PickupType type;

  PickupItem({
    required this.type,
    required Sprite sprite,
    required Vector2 size,
    required Vector2 position,
  }) : super(sprite: sprite, size: size, position: position);

  static Future<PickupItem> create(PickupType type, Vector2 position) async {
    late final Sprite sprite;

    switch (type) {
      case PickupType.package:
        sprite = await Sprite.load('pickup_package.png');
        break;
      case PickupType.coffee:
        sprite = await Sprite.load('pickup_coffee.png');
        break;
      case PickupType.pizza:
        sprite = await Sprite.load('pickup_pizza.png');
        break;
      case PickupType.fuel:
        sprite = await Sprite.load('pickup_fuel.png');
        break;
    }

    return PickupItem(
      type: type,
      sprite: sprite,
      size: Vector2(200, 200),
      position: position,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += 200 * dt;
  }
}
