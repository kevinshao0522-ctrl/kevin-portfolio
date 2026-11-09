/**
 * Don't Crash!! — Star Wars theme (Scheme A)
 *
 * Movement model:
 * - Player ship stays at the centre forever.
 * - Arrow keys will move aliens + starfield the opposite way (Phase 3),
 *   so it FEELS like the ship is flying.
 *
 * Phase 2 goals:
 * - Player class (centred spaceship)
 * - Obstacle class (aliens)
 * - At least two alien objects on screen
 * - Simple starfield background (static for now)
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
final int STAR_COUNT = 80;
float[] starX = new float[STAR_COUNT];
float[] starY = new float[STAR_COUNT];
float[] starBright = new float[STAR_COUNT];

void setup() {
  size(800, 600);
  textAlign(CENTER, CENTER);

  // Create the fixed player ship at the centre
  player = new Player();

  // At least TWO obstacle objects (marking band 40–50%)
  // Placed away from the centre so you can see them clearly.
  alien1 = new Obstacle(150, 120, 48, 3.0, color(120, 220, 120));
  alien2 = new Obstacle(650, 450, 56, 2.5, color(220, 120, 255));

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
  textSize(42);
  text("Don't Crash!!", width / 2, height / 2 - 50);

  textSize(18);
  fill(180);
  text("Star fighter — stay centred, push aliens away", width / 2, height / 2);
  text("Phase 2 — Player + two aliens", width / 2, height / 2 + 30);
  text("Press ENTER to start", width / 2, height / 2 + 60);
}

/**
 * PLAYING screen for Phase 2:
 * draw stars, two aliens, and the centred ship.
 * No keyboard movement yet (that is Phase 3).
 */
void drawPlaying() {
  drawStarfield();

  alien1.display();
  alien2.display();
  player.display();

  // Simple HUD
  fill(200);
  textSize(14);
  textAlign(LEFT, TOP);
  text("Lives: " + player.lives, 16, 16);
  text("Phase 2: ship fixed at centre (controls next)", 16, 36);
  textAlign(CENTER, CENTER);
}

void keyPressed() {
  if (gameState == STATE_START && (key == ENTER || key == RETURN)) {
    gameState = STATE_PLAYING;
    println("Entered PLAYING — Phase 2: player + 2 aliens visible");
  }
}
