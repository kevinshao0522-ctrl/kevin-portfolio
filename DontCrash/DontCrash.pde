/**
 * Don't Crash!! — Phase 1: project skeleton
 *
 * Goal of this phase:
 * - Open a game window
 * - Draw a simple title screen
 * - Define game states (not fully used yet)
 *
 * Next phase will add Player and Obstacle classes.
 */

// ---------- Game states (enum-like constants) ----------
// Using int constants keeps the code easy for beginners.
// Later we switch behaviour in draw() with these values.
final int STATE_START = 0;
final int STATE_PLAYING = 1;
final int STATE_GAME_OVER = 2;

// Current state: begin on the start screen
int gameState = STATE_START;

/**
 * setup() runs once when the program starts.
 * Processing requires size() (or fullScreen()) to be called here.
 */
void setup() {
  size(800, 600);          // Window size: 800 x 600 pixels
  textAlign(CENTER, CENTER);
}

/**
 * draw() runs about 60 times per second (the animation loop).
 * All continuous drawing / updates eventually go here.
 */
void draw() {
  background(24, 28, 40);  // Dark blue-grey background each frame

  // Phase 1: only handle START visually.
  // PLAYING / GAME_OVER will be filled in later phases.
  switch (gameState) {
    case STATE_START:
      drawStartScreen();
      break;
    case STATE_PLAYING:
      // TODO Phase 2+: draw player, obstacles, HUD
      break;
    case STATE_GAME_OVER:
      // TODO later: show score / restart hint
      break;
  }
}

/**
 * Draw the title / start screen.
 * Press ENTER (or RETURN) to enter PLAYING state.
 */
void drawStartScreen() {
  fill(240);
  textSize(42);
  text("Don't Crash!!", width / 2, height / 2 - 40);

  textSize(18);
  fill(180);
  text("Phase 1 — project skeleton", width / 2, height / 2 + 10);
  text("Press ENTER to start (placeholder)", width / 2, height / 2 + 40);
}

/**
 * keyPressed() is called by Processing when any key is pressed.
 * We only use it lightly in Phase 1 to test state change.
 */
void keyPressed() {
  if (gameState == STATE_START && (key == ENTER || key == RETURN)) {
    gameState = STATE_PLAYING;
    println("Entered PLAYING state (Phase 1 placeholder)");
  }
}
