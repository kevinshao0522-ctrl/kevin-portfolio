/**
 * Don't Crash!! — Star Wars theme (Scheme A)
 *
 * Phase 6:
 * - Inheritance: FastObstacle + MovingObstacle extend Obstacle
 * - ArrayList<Obstacle> stores mixed types (polymorphism)
 * - Player ship facing / appearance changes with arrow keys
 */

// ---------- Game states ----------
final int STATE_START = 0;
final int STATE_PLAYING = 1;
final int STATE_GAME_OVER = 2;

int gameState = STATE_START;

// ---------- Game entities ----------
Player player;

// Phase 5: dynamic list instead of fixed alien1 / alien2 variables
ArrayList<Obstacle> aliens;

// Health pickups: spawn still, no self-movement; max 3 lives
ArrayList<HealthPack> healthPacks;
int framesUntilHealthSpawn = 0;
final int HEALTH_SPAWN_MIN = 240;    // ~4s
final int HEALTH_SPAWN_MAX = 420;    // ~7s
final int MAX_HEALTH_PACKS = 2;

// Alien sprites (loaded once in setup)
PImage imgAlienGreen;
PImage imgAlienPurple;
PImage imgAlienOrange;

// Spawn control
int framesUntilSpawn = 0;
final int SPAWN_INTERVAL_MIN = 45;   // ~0.75s
final int SPAWN_INTERVAL_MAX = 100;  // ~1.7s
final int MAX_ALIENS = 12;           // soft cap to keep the game readable

// ---------- Keyboard push ----------
boolean holdLeft = false;
boolean holdRight = false;
boolean holdUp = false;
boolean holdDown = false;
float pushSpeed = 6.0;

// ---------- Collision feedback ----------
int invulnFrames = 0;
final int INVULN_DURATION = 90;
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
  imageMode(CENTER);

  // Load obstacle images from the data folder (PImage)
  imgAlienGreen = loadImage("alien_green.png");
  imgAlienPurple = loadImage("alien_purple.png");
  imgAlienOrange = loadImage("alien_orange.png");

  player = new Player();
  aliens = new ArrayList<Obstacle>();
  healthPacks = new ArrayList<HealthPack>();
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

  // Push EVERY alien in the list the same way
  for (Obstacle alien : aliens) {
    alien.moveBy(dx, dy);
  }
  // Health packs stay still by themselves, but move with world push
  for (HealthPack pack : healthPacks) {
    pack.moveBy(dx, dy);
  }
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
  text("Phase 6+ — heal packs (green +) restore life to max 3", width / 2, height / 2 + 58);
  text("Press ENTER to start", width / 2, height / 2 + 96);
}

void drawPlaying() {
  applyArrowPush();

  // Phase 6: ship nose turns with arrow keys (position still fixed)
  player.updateFacing(holdLeft, holdRight, holdUp, holdDown);

  // Spawn new aliens over time
  framesUntilSpawn--;
  if (framesUntilSpawn <= 0) {
    spawnAlienAtEdge();
    framesUntilSpawn = int(random(SPAWN_INTERVAL_MIN, SPAWN_INTERVAL_MAX));
  }

  // Spawn health packs over time (they do not self-move)
  framesUntilHealthSpawn--;
  if (framesUntilHealthSpawn <= 0) {
    spawnHealthPack();
    framesUntilHealthSpawn = int(random(HEALTH_SPAWN_MIN, HEALTH_SPAWN_MAX));
  }

  // Update + remove off-screen aliens (iterate backwards for safe remove)
  for (int i = aliens.size() - 1; i >= 0; i--) {
    Obstacle alien = aliens.get(i);
    alien.update();
    if (alien.isOffScreen()) {
      aliens.remove(i);   // free the object from the list
    }
  }

  // Remove health packs pushed far off-screen (no self update)
  for (int i = healthPacks.size() - 1; i >= 0; i--) {
    if (healthPacks.get(i).isOffScreen()) {
      healthPacks.remove(i);
    }
  }

  if (invulnFrames > 0) invulnFrames--;
  if (hitMessageFrames > 0) hitMessageFrames--;

  // Pick up health before alien damage checks
  handleHealthPickups();

  // Collision against every remaining alien
  if (invulnFrames <= 0) {
    for (int i = aliens.size() - 1; i >= 0; i--) {
      if (handleCollisionWith(aliens.get(i), i)) {
        break; // one hit per invuln window is enough
      }
    }
  }

  drawStarfield();

  for (HealthPack pack : healthPacks) {
    pack.display();
  }

  for (Obstacle alien : aliens) {
    alien.display();
  }

  if (invulnFrames <= 0 || (frameCount / 4) % 2 == 0) {
    player.display();
  }

  if (hitMessageFrames > 60) {
    fill(255, 40, 40, 60);
    rect(0, 0, width, height);
  }

  fill(200);
  textSize(16);
  textAlign(LEFT, TOP);
  text("Lives: " + player.lives, 20, 20);
  text("Aliens: " + aliens.size() + " / " + MAX_ALIENS, 20, 44);
  text("Arrows: push world opposite | ship facing changes", 20, 68);
  text("Types: normal / FAST (orange) / zig-zag (ring)", 20, 92);
  text("Green + : heal pack (max 3 lives)", 20, 116);
  textAlign(CENTER, CENTER);

  if (hitMessageFrames > 0) {
    fill(255, 220, 80);
    textSize(36);
    text(hitMessage, width / 2, 80);
  }
}

/**
 * Place a health pack somewhere on screen, away from the centred ship.
 * It will stay where it is until arrow-key world push moves it.
 */
void spawnHealthPack() {
  if (healthPacks.size() >= MAX_HEALTH_PACKS) return;

  float px, py;
  // Keep it away from the player centre so it is not auto-collected
  do {
    px = random(80, width - 80);
    py = random(80, height - 80);
  } while (dist(px, py, width / 2.0, height / 2.0) < 180);

  healthPacks.add(new HealthPack(px, py));
}

/** Touch a pack → +1 life (cap 3), then remove the pack. */
void handleHealthPickups() {
  for (int i = healthPacks.size() - 1; i >= 0; i--) {
    HealthPack pack = healthPacks.get(i);
    if (!pack.touchesPlayer(player)) continue;

    if (player.heal(1)) {
      hitMessageFrames = 70;
      hitMessage = "HEAL! Lives: " + player.lives + " / 3";
      println(hitMessage);
    } else {
      hitMessageFrames = 70;
      hitMessage = "Already full HP (3)";
    }
    healthPacks.remove(i);
  }
}

/**
 * Create one new alien just outside the screen and add it to the ArrayList.
 * Randomly chooses a subclass so the list holds mixed Obstacle types.
 */
void spawnAlienAtEdge() {
  if (aliens.size() >= MAX_ALIENS) return;

  float sz = random(48, 70);
  float roll = random(1);
  Obstacle alien;

  if (roll < 0.35) {
    // Fast orange hunter
    alien = new FastObstacle(0, 0, sz * 0.9, imgAlienOrange);
  } else if (roll < 0.65) {
    // Zig-zag purple mover
    alien = new MovingObstacle(0, 0, sz, imgAlienPurple);
  } else {
    // Normal green wanderer
    alien = new Obstacle(0, 0, sz, random(1.6, 3.0), color(120, 220, 120), imgAlienGreen);
  }

  alien.respawnAtEdge();
  aliens.add(alien);  // polymorphism: subclass stored as Obstacle
}

/**
 * @return true if a collision happened and was handled
 */
boolean handleCollisionWith(Obstacle alien, int index) {
  if (!player.checkCollision(alien)) return false;

  player.lives--;
  invulnFrames = INVULN_DURATION;
  hitMessageFrames = 90;
  hitMessage = "CRASH! Lives left: " + player.lives;
  println(hitMessage);

  // Remove the alien from memory/list instead of keeping it around
  aliens.remove(index);

  if (player.lives <= 0) {
    gameState = STATE_GAME_OVER;
    clearHoldKeys();
    println("GAME OVER");
  }
  return true;
}

void drawGameOver() {
  drawStarfield();
  for (HealthPack pack : healthPacks) {
    pack.display();
  }
  for (Obstacle alien : aliens) {
    alien.display();
  }
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

void restartGame() {
  player.lives = 3;
  invulnFrames = 0;
  hitMessageFrames = 0;
  hitMessage = "";
  clearHoldKeys();

  // Clear old lists, then seed with visible aliens + one heal pack
  aliens.clear();
  healthPacks.clear();

  // Seed with different subclasses so inheritance is visible immediately
  Obstacle a1 = new Obstacle(180, 140, 56, 2.2, color(120, 220, 120), imgAlienGreen);
  a1.placeOnScreen(180, 140);
  aliens.add(a1);

  FastObstacle a2 = new FastObstacle(width - 200, 160, 50, imgAlienOrange);
  a2.placeOnScreen(width - 200, 160);
  aliens.add(a2);

  MovingObstacle a3 = new MovingObstacle(width / 2, height - 140, 58, imgAlienPurple);
  a3.placeOnScreen(width / 2, height - 140);
  aliens.add(a3);

  // One stationary heal pack at start (away from centre)
  healthPacks.add(new HealthPack(220, height - 180));

  framesUntilSpawn = SPAWN_INTERVAL_MIN;
  framesUntilHealthSpawn = HEALTH_SPAWN_MIN;
  gameState = STATE_PLAYING;
  println("Restarted — heal packs enabled, aliens=" + aliens.size());
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
