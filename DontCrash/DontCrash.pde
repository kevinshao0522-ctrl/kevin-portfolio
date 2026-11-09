/**
 * Don't Crash!! — Star Wars theme (Scheme A)
 *
 * Phase 4:
 * - Player.checkCollision(Obstacle)
 * - Obvious response: lives down, flash message, alien respawns
 * - GAME_OVER when lives reach 0
 */

// ---------- Game states ----------
final int STATE_START = 0;
final int STATE_PLAYING = 1;
final int STATE_GAME_OVER = 2;

int gameState = STATE_START;

// ---------- Game entities ----------
Player player;
Obstacle alien1;
Obstacle alien2;

// ---------- Keyboard push (Phase 3) ----------
boolean holdLeft = false;
boolean holdRight = false;
boolean holdUp = false;
boolean holdDown = false;
float pushSpeed = 6.0;

// ---------- Collision feedback (Phase 4) ----------
// After a hit, briefly ignore new collisions so one overlap
// does not remove all lives in a few frames.
int invulnFrames = 0;
final int INVULN_DURATION = 90;   // ~1.5 seconds at 60fps

// On-screen collision message timer
int hitMessageFrames = 0;
String hitMessage = "";

// ---------- Starfield ----------
final int STAR_COUNT = 140;
float[] starX = new float[STAR_COUNT];
float[] starY = new float[STAR_COUNT];
float[] starBright = new float[STAR_COUNT];

void setup() {
  size(1280, 800);
  textAlign(CENTER, CENTER);

  player = new Player();
  alien1 = new Obstacle(180, 140, 56, 2.2, color(120, 220, 120));
  alien2 = new Obstacle(1100, 640, 64, 1.8, color(220, 120, 255));
  initStarfield();
}

void draw() {
  background(8, 10, 24);

  switch (gameState) {
    case STATE_START:
      drawStarfield();
      drawStartScreen();
      break;
    case STATE_PLAYING:
      drawPlaying();
      break;
    case STATE_GAME_OVER:
      drawGameOver();
      break;
  }
}

void initStarfield() {
  for (int i = 0; i < STAR_COUNT; i++) {
    starX[i] = random(width);
    starY[i] = random(height);
    starBright[i] = random(120, 255);
  }
}

void drawStarfield() {
  noStroke();
  for (int i = 0; i < STAR_COUNT; i++) {
    fill(starBright[i]);
    circle(starX[i], starY[i], 2);
  }
}

void shiftStarfield(float dx, float dy) {
  for (int i = 0; i < STAR_COUNT; i++) {
    starX[i] += dx;
    starY[i] += dy;
    if (starX[i] < 0) starX[i] += width;
    if (starX[i] >= width) starX[i] -= width;
    if (starY[i] < 0) starY[i] += height;
    if (starY[i] >= height) starY[i] -= height;
  }
}

void applyArrowPush() {
  float dx = 0;
  float dy = 0;

  if (holdLeft)  dx += pushSpeed;
  if (holdRight) dx -= pushSpeed;
  if (holdUp)    dy += pushSpeed;
  if (holdDown)  dy -= pushSpeed;

  if (dx == 0 && dy == 0) return;

  alien1.moveBy(dx, dy);
  alien2.moveBy(dx, dy);
  shiftStarfield(dx, dy);
}

void drawStartScreen() {
  fill(240);
  textSize(52);
  text("Don't Crash!!", width / 2, height / 2 - 70);

  textSize(20);
  fill(180);
  text("Star fighter — ship stays centred", width / 2, height / 2 - 10);
  text("Arrow keys push aliens & stars the OPPOSITE way", width / 2, height / 2 + 26);
  text("Phase 4 — collision & lives", width / 2, height / 2 + 58);
  text("Press ENTER to start", width / 2, height / 2 + 96);
}

void drawPlaying() {
  applyArrowPush();

  alien1.update();
  alien2.update();

  // Count down invulnerability / message timers
  if (invulnFrames > 0) invulnFrames--;
  if (hitMessageFrames > 0) hitMessageFrames--;

  // Collision checks (only when not invulnerable)
  if (invulnFrames <= 0) {
    handleCollisionWith(alien1);
  }
  if (invulnFrames <= 0) {
    handleCollisionWith(alien2);
  }

  drawStarfield();
  alien1.display();
  alien2.display();

  // Flash the ship while invulnerable
  if (invulnFrames <= 0 || (frameCount / 4) % 2 == 0) {
    player.display();
  }

  // Red flash overlay right after a hit
  if (hitMessageFrames > 60) {
    fill(255, 40, 40, 60);
    rect(0, 0, width, height);
  }

  // HUD
  fill(200);
  textSize(16);
  textAlign(LEFT, TOP);
  text("Lives: " + player.lives, 20, 20);
  text("Arrows: push world opposite | Avoid aliens", 20, 44);
  textAlign(CENTER, CENTER);

  // Collision message
  if (hitMessageFrames > 0) {
    fill(255, 220, 80);
    textSize(36);
    text(hitMessage, width / 2, 80);
  }
}

/**
 * If the player overlaps this alien:
 * - reduce lives
 * - show a clear on-screen message
 * - respawn the alien away from the ship
 * - start a short invulnerability window
 * - go to GAME_OVER when lives hit 0
 */
void handleCollisionWith(Obstacle alien) {
  if (!player.checkCollision(alien)) return;

  player.lives--;
  invulnFrames = INVULN_DURATION;
  hitMessageFrames = 90;
  hitMessage = "CRASH! Lives left: " + player.lives;
  println(hitMessage);

  // Obvious response: remove this alien from the danger zone
  alien.respawnAtEdge();

  if (player.lives <= 0) {
    gameState = STATE_GAME_OVER;
    clearHoldKeys();
    println("GAME OVER");
  }
}

void drawGameOver() {
  drawStarfield();
  player.display();

  fill(0, 0, 0, 160);
  rect(0, 0, width, height);

  fill(255, 80, 80);
  textSize(56);
  text("GAME OVER", width / 2, height / 2 - 40);

  fill(220);
  textSize(22);
  text("You crashed into too many aliens", width / 2, height / 2 + 20);
  text("Press ENTER to restart", width / 2, height / 2 + 56);
}

/** Reset lives / aliens / timers for a fresh run. */
void restartGame() {
  player.lives = 3;
  invulnFrames = 0;
  hitMessageFrames = 0;
  hitMessage = "";
  alien1.respawnAtEdge();
  alien2.respawnAtEdge();
  clearHoldKeys();
  gameState = STATE_PLAYING;
  println("Restarted — Phase 4 collision active");
}

void clearHoldKeys() {
  holdLeft = false;
  holdRight = false;
  holdUp = false;
  holdDown = false;
}

void keyPressed() {
  if ((gameState == STATE_START || gameState == STATE_GAME_OVER) &&
      (key == ENTER || key == RETURN)) {
    restartGame();
    return;
  }

  if (gameState != STATE_PLAYING) return;

  if (keyCode == LEFT)  holdLeft = true;
  if (keyCode == RIGHT) holdRight = true;
  if (keyCode == UP)    holdUp = true;
  if (keyCode == DOWN)  holdDown = true;
}

void keyReleased() {
  if (keyCode == LEFT)  holdLeft = false;
  if (keyCode == RIGHT) holdRight = false;
  if (keyCode == UP)    holdUp = false;
  if (keyCode == DOWN)  holdDown = false;
}
