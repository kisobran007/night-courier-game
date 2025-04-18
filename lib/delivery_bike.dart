import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';

class DeliveryBike extends SpriteComponent with HasGameRef {
  DeliveryBike({
    required super.sprite,
    required super.size,
    required super.position,
  });

  @override
  Future<void> onLoad() async {
    super.onLoad();
    addBounceEffect();
  }

  void addBounceEffect() {
    final controller = EffectController(
      duration: 0.6,
      reverseDuration: 0.6,
      infinite: true,
      curve: Curves.easeInOut,
    );

    final bounce = MoveByEffect(
      Vector2(0, -5),
      controller,
    );

    add(bounce);
  }
  void clearEffects() {
    final currentEffects = List<Effect>.from(children.whereType<Effect>());
    for (final effect in currentEffects) {
      effect.removeFromParent();
    }
  }
}