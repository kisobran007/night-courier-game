import 'package:flame/components.dart';

class GameManager extends Component {
  bool isGameOver = false;
  double fuel = 100;

  void reset() {
    isGameOver = false;
    refillFuel(100);
  }
  void triggerGameOver() {
    isGameOver = true;
  }
  void refillFuel(double amount) {
    fuel += amount;
    if (fuel > 100) fuel = 100;
  }
  void consumeFuel(double amount) {
    fuel -= amount;
    if (fuel <= 0) {
      fuel = 0;
      triggerGameOver();
    }
  }
}