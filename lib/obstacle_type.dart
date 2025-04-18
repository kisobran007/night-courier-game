enum ObstacleType { car, cones, manhole }

extension ObstacleTypeExtension on ObstacleType {
  int get penalty {
    switch (this) {
      case ObstacleType.car:
        return 20;
      case ObstacleType.cones:
        return 10;
      case ObstacleType.manhole:
        return 15;
    }
  }
}