/**
 * Don't Crash!! — Star Wars theme (Scheme A)
 *
 * Syllabus-safe rewrite:
 * - No trig / matrix / noise / file I/O
 * - if/else states, key polling, discrete facing
 */

// ---------- Game states ----------
final int STATE_START = 0;
final int STATE_PLAYING = 1;
final int STATE_GAME_OVER = 2;

int gameState = STATE_START;

Player player;
ScoreManager scores;

ArrayList<Obstacle> aliens;
ArrayList<HealthPack> healthPacks;
ArrayList<GameEntity> effects;
ArrayList<Bullet> bullets;

int fireCooldown = 0;
final int FIRE_COOLDOWN_FRAMES = 12;
final float BULLET_SPEED = 14;

int framesUntilHealthSpawn = 0;
final int HEALTH_SPAWN_MIN = 240;
final int HEALTH_SPAWN_MAX = 420;
final int MAX_HEALTH_PACKS = 2;

PImage imgAlienGreen;
PImage imgAlienPurple;
PImage imgAlienOrange;
PImage imgShipUp;
PImage imgShipDown;
PImage imgShipLeft;
PImage imgShipRight;

int framesUntilSpawn = 0;
final int SPAWN_INTERVAL_MIN = 45;
final int SPAWN_INTERVAL_MAX = 100;
final int MAX_ALIENS = 12;

// Hold flags — updated in keyPressed / keyReleased for instant response
boolean holdLeft = false;
boolean holdRight = false;
boolean holdUp = false;
boolean holdDown = false;
float pushSpeed = 6.0;

int invulnFrames = 0;
final int INVULN_DURATION = 90;
int hitMessageFrames = 0;
String hitMessage = "";
int healFlashFrames = 0;
int crashFlashFrames = 0;

final int STAR_COUNT = 140;
float[] starX = new float[STAR_COUNT];
float[] starY = new float[STAR_COUNT];
float[] starBright = new float[STAR_COUNT];

void setup() {
  size(1280, 800);
  textAlign(CENTER, CENTER);

  imgAlienGreen = loadImage("alien_green.png");
  imgAlienPurple = loadImage("alien_purple.png");
  imgAlienOrange = loadImage("alien_orange.png");
  // Four facing sprites (pre-rotated offline — no rotate() in game code)
  imgShipUp = loadImage("player_ship_up.png");
  imgShipDown = loadImage("player_ship_down.png");
  imgShipLeft = loadImage("player_ship_left.png");
  imgShipRight = loadImage("player_ship_right.png");

  player = new Player(imgShipUp, imgShipDown, imgShipLeft, imgShipRight);
  scores = new ScoreManager();
  aliens = new ArrayList<Obstacle>();
  healthPacks = new ArrayList<HealthPack>();
  effects = new ArrayList<GameEntity>();
  bullets = new ArrayList<Bullet>();
  initStarfield();
}

void draw() {
  // Solid background colour changes for flash feedback (no alpha fill)
  if (gameState == STATE_PLAYING && healFlashFrames > 0) {
    background(30, 140, 70);
  } else if (gameState == STATE_PLAYING && crashFlashFrames > 0) {
    background(140, 40, 40);
  } else {
    background(8, 10, 24);
  }

  if (gameState == STATE_START) {
    drawStarfield();
    drawStartScreen();
  } else if (gameState == STATE_PLAYING) {
    drawPlaying();
  } else if (gameState == STATE_GAME_OVER) {
    drawGameOver();
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
    ellipse(starX[i], starY[i], 2, 2);
  }
}

void shiftStarfield(float dx, float dy) {
  for (int i = 0; i < STAR_COUNT; i++) {
    starX[i] = starX[i] + dx;
    starY[i] = starY[i] + dy;
    if (starX[i] < 0) starX[i] = starX[i] + width;
    if (starX[i] >= width) starX[i] = starX[i] - width;
    if (starY[i] < 0) starY[i] = starY[i] + height;
    if (starY[i] >= height) starY[i] = starY[i] - height;
  }
}

/**
 * Use hold flags so direction changes immediately when a key goes down,
 * and stops immediately when released (no OS key-repeat delay).
 */
void applyArrowPush() {
  float dx = 0;
  float dy = 0;

  if (holdLeft)  dx = dx + pushSpeed;
  if (holdRight) dx = dx - pushSpeed;
  if (holdUp)    dy = dy + pushSpeed;
  if (holdDown)  dy = dy - pushSpeed;

  // Update ship facing from currently held keys
  player.updateFacing(holdLeft, holdRight, holdUp, holdDown);

  if (dx == 0 && dy == 0) return;

  for (Obstacle alien : aliens) {
    alien.moveBy(dx, dy);
  }
  for (HealthPack pack : healthPacks) {
    pack.moveBy(dx, dy);
  }
  for (GameEntity e : effects) {
    e.moveBy(dx, dy);
  }
  for (Bullet b : bullets) {
    b.moveBy(dx, dy);
  }
  shiftStarfield(dx, dy);
}

void drawStartScreen() {
  fill(240);
  textSize(64);
  text("Don't Crash!!", width / 2, height / 2 - 30);

  textSize(22);
  fill(180);
  text("Press ENTER to start", width / 2, height / 2 + 40);
}

void drawPlaying() {
  applyArrowPush();
  player.update();
  scores.updateSurvivalScore();

  framesUntilSpawn--;
  if (framesUntilSpawn <= 0) {
    spawnAlienAtEdge();
    framesUntilSpawn = int(random(SPAWN_INTERVAL_MIN, SPAWN_INTERVAL_MAX));
  }

  framesUntilHealthSpawn--;
  if (framesUntilHealthSpawn <= 0) {
    spawnHealthPack();
    framesUntilHealthSpawn = int(random(HEALTH_SPAWN_MIN, HEALTH_SPAWN_MAX));
  }

  for (int i = aliens.size() - 1; i >= 0; i--) {
    Obstacle alien = aliens.get(i);
    alien.update();
    if (alien.isOffScreen()) {
      aliens.remove(i);
    }
  }

  for (int i = healthPacks.size() - 1; i >= 0; i--) {
    HealthPack pack = healthPacks.get(i);
    pack.update();
    if (pack.isOffScreen()) {
      healthPacks.remove(i);
    }
  }

  for (int i = effects.size() - 1; i >= 0; i--) {
    GameEntity e = effects.get(i);
    e.update();
    if (e.isFinished()) {
      effects.remove(i);
    }
  }

  if (fireCooldown > 0) fireCooldown--;
  for (int i = bullets.size() - 1; i >= 0; i--) {
    Bullet b = bullets.get(i);
    b.update();
    if (b.isFinished()) {
      bullets.remove(i);
      continue;
    }
    for (int j = aliens.size() - 1; j >= 0; j--) {
      Obstacle alien = aliens.get(j);
      if (b.hits(alien)) {
        effects.add(new Explosion(alien.x, alien.y));
        scores.addBonus(10);
        hitMessageFrames = 45;
        hitMessage = "HIT! +10";
        aliens.remove(j);
        b.markDead();
        bullets.remove(i);
        break;
      }
    }
  }

  if (invulnFrames > 0) invulnFrames--;
  if (hitMessageFrames > 0) hitMessageFrames--;
  if (healFlashFrames > 0) healFlashFrames--;
  if (crashFlashFrames > 0) crashFlashFrames--;

  handleHealthPickups();

  if (invulnFrames <= 0) {
    for (int i = aliens.size() - 1; i >= 0; i--) {
      if (handleCollisionWith(aliens.get(i), i)) {
        break;
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
  for (Bullet b : bullets) {
    b.display();
  }
  for (GameEntity e : effects) {
    e.display();
  }

  if (invulnFrames <= 0 || (frameCount / 4) % 2 == 0) {
    player.display();
  }

  fill(200);
  textSize(16);
  textAlign(LEFT, TOP);
  text("Lives: " + player.lives, 20, 20);
  text("Score: " + scores.currentScore, 20, 44);
  textAlign(CENTER, CENTER);

  if (hitMessageFrames > 0) {
    fill(255, 220, 80);
    textSize(36);
    text(hitMessage, width / 2, 80);
  }
}

void spawnHealthPack() {
  if (healthPacks.size() >= MAX_HEALTH_PACKS) return;

  float px = random(80, width - 80);
  float py = random(80, height - 80);

  // Retry with while (not do-while) until far enough from centre
  int tries = 0;
  while (dist(px, py, width / 2.0, height / 2.0) < 180 && tries < 30) {
    px = random(80, width - 80);
    py = random(80, height - 80);
    tries++;
  }

  healthPacks.add(new HealthPack(px, py));
}

void handleHealthPickups() {
  for (int i = healthPacks.size() - 1; i >= 0; i--) {
    HealthPack pack = healthPacks.get(i);
    if (!pack.touchesPlayer(player)) continue;

    healFlashFrames = 45;

    if (player.heal(1)) {
      scores.addBonus(5);
      hitMessageFrames = 70;
      hitMessage = "HEAL! +5 score | Lives: " + player.lives + "/3";
    } else {
      hitMessageFrames = 70;
      hitMessage = "Already full HP (3)";
    }
    healthPacks.remove(i);
  }
}

void spawnAlienAtEdge() {
  if (aliens.size() >= MAX_ALIENS) return;

  float sz = random(48, 70);
  float roll = random(1);
  Obstacle alien;

  if (roll < 0.35) {
    alien = new FastObstacle(0, 0, sz * 0.9, imgAlienOrange);
  } else if (roll < 0.65) {
    alien = new MovingObstacle(0, 0, sz, imgAlienPurple);
  } else {
    alien = new Obstacle(0, 0, sz, random(1.6, 3.0), color(120, 220, 120), imgAlienGreen);
  }

  alien.respawnAtEdge();
  aliens.add(alien);
}

boolean handleCollisionWith(Obstacle alien, int index) {
  if (!player.checkCollision(alien)) return false;

  player.lives--;
  invulnFrames = INVULN_DURATION;
  hitMessageFrames = 90;
  crashFlashFrames = 20;
  hitMessage = "CRASH! Lives left: " + player.lives;
  println(hitMessage);

  effects.add(new Explosion(alien.x, alien.y));
  aliens.remove(index);

  if (player.lives <= 0) {
    endRun();
  }
  return true;
}

void endRun() {
  gameState = STATE_GAME_OVER;
  clearHoldKeys();
  scores.saveHighScore();
  println("GAME OVER — score=" + scores.currentScore + " high=" + scores.highScore);
}

void drawGameOver() {
  drawStarfield();
  for (HealthPack pack : healthPacks) {
    pack.display();
  }
  for (Obstacle alien : aliens) {
    alien.display();
  }
  for (Bullet b : bullets) {
    b.display();
  }
  for (GameEntity e : effects) {
    e.display();
  }
  player.display();

  // Opaque dark panel (no alpha)
  fill(20, 20, 30);
  rect(0, 0, width, height);

  // Redraw text on top of panel — need entities already drawn above; panel covers them.
  // Re-show scores only:
  fill(255, 80, 80);
  textSize(56);
  text("GAME OVER", width / 2, height / 2 - 70);

  fill(220);
  textSize(24);
  text("Score: " + scores.currentScore, width / 2, height / 2 - 10);
  text("High Score: " + scores.highScore, width / 2, height / 2 + 26);

  if (scores.currentScore >= scores.highScore && scores.currentScore > 0) {
    fill(255, 220, 80);
    text("New record this run!", width / 2, height / 2 + 64);
  }

  fill(200);
  textSize(20);
  text("Press ENTER to restart", width / 2, height / 2 + 110);
}

void restartGame() {
  player.lives = 3;
  player.facing = player.DIR_UP;
  invulnFrames = 0;
  hitMessageFrames = 0;
  hitMessage = "";
  healFlashFrames = 0;
  crashFlashFrames = 0;
  clearHoldKeys();
  scores.resetRun();

  aliens.clear();
  healthPacks.clear();
  effects.clear();
  bullets.clear();
  fireCooldown = 0;

  Obstacle a1 = new Obstacle(180, 140, 56, 2.2, color(120, 220, 120), imgAlienGreen);
  a1.placeOnScreen(180, 140);
  aliens.add(a1);

  FastObstacle a2 = new FastObstacle(width - 200, 160, 50, imgAlienOrange);
  a2.placeOnScreen(width - 200, 160);
  aliens.add(a2);

  MovingObstacle a3 = new MovingObstacle(width / 2, height - 140, 58, imgAlienPurple);
  a3.placeOnScreen(width / 2, height - 140);
  aliens.add(a3);

  healthPacks.add(new HealthPack(220, height - 180));

  framesUntilSpawn = SPAWN_INTERVAL_MIN;
  framesUntilHealthSpawn = HEALTH_SPAWN_MIN;
  gameState = STATE_PLAYING;
  println("Restarted — syllabus-safe controls");
}

void tryFireBullet() {
  if (fireCooldown > 0) return;

  float noseX = player.getNoseX();
  float noseY = player.getNoseY();
  float bvx = player.getBulletVx(BULLET_SPEED);
  float bvy = player.getBulletVy(BULLET_SPEED);
  bullets.add(new Bullet(noseX, noseY, bvx, bvy));
  fireCooldown = FIRE_COOLDOWN_FRAMES;
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

  if (key == ' ') {
    tryFireBullet();
  }
}

void keyReleased() {
  if (keyCode == LEFT)  holdLeft = false;
  if (keyCode == RIGHT) holdRight = false;
  if (keyCode == UP)    holdUp = false;
  if (keyCode == DOWN)  holdDown = false;
}

void clearHoldKeys() {
  holdLeft = false;
  holdRight = false;
  holdUp = false;
  holdDown = false;
}
