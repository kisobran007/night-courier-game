enum PickupType { package, coffee, pizza, fuel }

extension PickupTypeExtension on PickupType {
  int get scoreValue {
    switch (this) {
      case PickupType.package:
        return 15;
      case PickupType.coffee:
        return 10;
      case PickupType.pizza:
        return 20;
      case PickupType.fuel:
        return 0;
    }
  }
}