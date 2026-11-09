/**
 * ScoreManager — current score + high score file handling.
 *
 * Uses Processing file I/O:
 * - loadStrings(filename)  read high score
 * - saveStrings(filename, lines)  write high score
 *
 * File is stored in the sketch folder as highscore.txt
 */
class ScoreManager {
  int currentScore;
  int highScore;
  final String FILE_NAME = "highscore.txt";

  // Accumulate frames to award 1 point per second (~60 frames)
  int frameCounter;

  ScoreManager() {
    currentScore = 0;
    highScore = 0;
    frameCounter = 0;
    loadHighScore();
  }

  /** Read the saved high score from disk (if the file exists). */
  void loadHighScore() {
    String[] lines = loadStrings(FILE_NAME);
    if (lines != null && lines.length > 0) {
      try {
        highScore = max(0, Integer.parseInt(trim(lines[0])));
      } catch (Exception e) {
        highScore = 0;
      }
    } else {
      highScore = 0;
    }
    println("Loaded high score: " + highScore);
  }

  /** If currentScore beats highScore, write it to highscore.txt */
  void saveHighScore() {
    if (currentScore > highScore) {
      highScore = currentScore;
      String[] lines = { str(highScore) };
      saveStrings(FILE_NAME, lines);
      println("New high score saved: " + highScore);
    }
  }

  void resetRun() {
    currentScore = 0;
    frameCounter = 0;
  }

  /** Call once per frame while PLAYING to earn survival points. */
  void updateSurvivalScore() {
    frameCounter++;
    if (frameCounter >= 60) {
      frameCounter = 0;
      currentScore += 1;
    }
  }

  void addBonus(int amount) {
    currentScore += amount;
  }

  boolean isNewRecord() {
    return currentScore > highScore;
  }
}
