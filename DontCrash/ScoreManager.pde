/**
 * ScoreManager.pde — Current score plus high score saved with file I/O.
 * Uses loadStrings / saveStrings on highscore.txt (70–80% criterion).
 */
class ScoreManager {
  private int currentScore;
  private int highScore;
  private int frameCounter;
  final String HIGH_SCORE_FILE = "data/highscore.txt";

  ScoreManager() {
    currentScore = 0;
    highScore = 0;
    frameCounter = 0;
    loadHighScore();
  }

  int getCurrentScore() {
    return currentScore;
  }

  int getHighScore() {
    return highScore;
  }

  // Level rises with score (optional feature from the brief)
  int getLevel() {
    if (currentScore >= 200) return 4;
    if (currentScore >= 100) return 3;
    if (currentScore >= 50) return 2;
    return 1;
  }

  void loadHighScore() {
    String[] lines = loadStrings(HIGH_SCORE_FILE);
    if (lines != null && lines.length > 0) {
      highScore = int(lines[0]);
      if (highScore < 0) {
        highScore = 0;
      }
      println("Loaded high score: " + highScore);
    } else {
      highScore = 0;
      println("No high score file yet — starting at 0");
    }
  }

  void saveHighScore() {
    if (currentScore > highScore) {
      highScore = currentScore;
      println("New high score: " + highScore);
    }
    String[] data = new String[1];
    data[0] = str(highScore);
    saveStrings(HIGH_SCORE_FILE, data);
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
