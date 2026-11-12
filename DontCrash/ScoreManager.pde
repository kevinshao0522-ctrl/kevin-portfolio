/**
 * ScoreManager.pde — Tracks current score and in-memory high score.
 * Survival points tick over time; bonuses come from hits and heals.
 */
class ScoreManager {
  private int currentScore;
  private int highScore;
  private int frameCounter;

  ScoreManager() {
    currentScore = 0;
    highScore = 0;
    frameCounter = 0;
  }

  int getCurrentScore() {
    return currentScore;
  }

  int getHighScore() {
    return highScore;
  }

  void saveHighScore() {
    if (currentScore > highScore) {
      highScore = currentScore;
      println("New high score (memory): " + highScore);
    }
  }

  void resetRun() {
    currentScore = 0;
    frameCounter = 0;
  }

  // About +1 score per second while playing
  void updateSurvivalScore() {
    frameCounter++;
    if (frameCounter >= 60) {
      frameCounter = 0;
      currentScore = currentScore + 1;
    }
  }

  void addBonus(int amount) {
    currentScore = currentScore + amount;
  }

  boolean isNewRecord() {
    return currentScore > highScore;
  }
}
