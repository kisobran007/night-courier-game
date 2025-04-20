class LevelManager {
  int currentLevel = 1;
  double levelTime = 300; // 5 minuta
  double timeRemaining = 300;
  int targetScore = 100;

  void nextLevel() {
    currentLevel++;
    levelTime = (300 - (currentLevel - 1) * 30).clamp(60, 300).toDouble(); // max 5 min, min 1 min
    targetScore += 50;
    timeRemaining = levelTime;
  }

  void update(double dt) {
    timeRemaining -= dt;
  }

  bool isTimeUp() => timeRemaining <= 0;

  void reset() {
    currentLevel = 1;
    levelTime = 300;
    timeRemaining = 300;
    targetScore = 100;
  }
}
