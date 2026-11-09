/**
 * Don't Crash!! — Star Wars theme (Scheme A)
 *
 * Movement model:
 * - Player ship stays at the centre forever.
 * - Aliens already drift on their own (Phase 2).
 * - Arrow keys will ADD opposite push to aliens + starfield (Phase 3),
 *   so it FEELS like the ship is flying.
 *
 * Phase 2 goals:
 * - Player class (centred spaceship)
 * - Obstacle class (aliens) with independent movement
 * - At least two alien objects on screen
 * - Larger play window + starfield
 */

// ---------- Game states ----------
final int STATE_START = 0;
final int STATE_PLAYING = 1;
final int STATE_GAME_OVER = 2;

int gameState = STATE_START;

// ---------- Game entities (Phase 2) ----------
Player player;
Obstacle alien1;
Obstacle alien2;

// ---------- Starfield (visual only; will scroll in Phase 3) ----------
final int STAR_COUNT = 140;
float[] starX = new float[STAR_COUNT];
float[] starY = new float[STAR_COUNT];
float[] starBright = new float[STAR_COUNT];

void setup() {
  // Larger play area for Scheme A space feel
  size(1280, 800);
  textAlign(CENTER, CENTER);

  // Create the fixed player ship at the centre
  player = new Player();

  // At least TWO obstacle objects (marking band 40–50%)
  // Start near opposite corners; they will drift toward the centre alone.
  alien1 = new Obstacle(180, 140, 56, 2.2, color(120, 220, 120));
  alien2 = new Obstacle(1100, 640, 64, 1.8, color(220, 120, 255));

  initStarfield();
}

void draw() {
  background(8, 10, 24);  // Deep space

  switch (gameState) {
    case STATE_START:
      drawStarfield();
      drawStartScreen();
      break;
    case STATE_PLAYING:
      drawPlaying();
      break;
    case STATE_GAME_OVER:
      // Phase 4+
      break;
  }
}

/** Fill star arrays with random positions. */
void initStarfield() {
  for (int i = 0; i < STAR_COUNT; i++) {
    starX[i] = random(width);
    starY[i] = random(height);
    starBright[i] = random(120, 255);
  }
}

/** Draw tiny stars. Phase 3 will shift these with arrow keys. */
void drawStarfield() {
  noStroke();
  for (int i = 0; i < STAR_COUNT; i++) {
    fill(starBright[i]);
    circle(starX[i], starY[i], 2);
  }
}

void drawStartScreen() {
  fill(240);
  textSize(52);
  text("Don't Crash!!", width / 2, height / 2 - 60);

  textSize(20);
  fill(180);
  text("Star fighter — stay centred, push aliens away", width / 2, height / 2);
  text("Phase 2 — aliens move on their own", width / 2, height / 2 + 36);
  text("Press ENTER to start", width / 2, height / 2 + 72);
}

/**
 * PLAYING screen for Phase 2:
 * aliens update themselves every frame; ship stays fixed at centre.
 */
void drawPlaying() {
  drawStarfield();

  // Independent movement (no keyboard required)
  alien1.update();
  alien2.update();

  alien1.display();
  alien2.display();
  player.display();

  // Simple HUD
  fill(200);
  textSize(16);
  textAlign(LEFT, TOP);
  text("Lives: " + player.lives, 20, 20);
  text("Aliens drift alone — arrow controls come in Phase 3", 20, 44);
  textAlign(CENTER, CENTER);
}

void keyPressed() {
  if (gameState == STATE_START && (key == ENTER || key == RETURN)) {
    gameState = STATE_PLAYING;
    println("Entered PLAYING — Phase 2: auto-moving aliens");
  }
}
