/**
 * ScoreManager — current score + high score in memory only.
 * (No file I/O — syllabus-safe version)
 */
class ScoreManager {
  int currentScore;
  int highScore;

  // Award 1 point about every 60 frames (~1 second)
  int frameCounter;

  ScoreManager() {
    currentScore = 0;
    highScore = 0;
    frameCounter = 0;
  }

  /** Keep the best score of this program run in memory. */
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
