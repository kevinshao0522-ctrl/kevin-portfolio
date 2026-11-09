/**
 * Don't Crash!! — Star Wars theme (Scheme A)
 *
 * Phase 8 (80%+):
 * - GameEntity interface + WorldObject abstract class
 * - Explosion collision animation while game continues
 * - Polymorphism across most entities
 */

// ---------- Game states ----------
final int STATE_START = 0;
final int STATE_PLAYING = 1;
final int STATE_GAME_OVER = 2;

int gameState = STATE_START;

// ---------- Game entities ----------
Player player;
ScoreManager scores;

ArrayList<Obstacle> aliens;
ArrayList<HealthPack> healthPacks;

// Polymorphic effects list (Explosions implement GameEntity)
ArrayList<GameEntity> effects;

// Player lasers (SPACE to fire)
ArrayList<Bullet> bullets;
int fireCooldown = 0;
final int FIRE_COOLDOWN_FRAMES = 12;  // ~5 shots/sec
final float BULLET_SPEED = 14;

int framesUntilHealthSpawn = 0;
final int HEALTH_SPAWN_MIN = 240;
final int HEALTH_SPAWN_MAX = 420;
final int MAX_HEALTH_PACKS = 2;

PImage imgAlienGreen;
PImage imgAlienPurple;
PImage imgAlienOrange;
PImage imgPlayerShip;

int framesUntilSpawn = 0;
final int SPAWN_INTERVAL_MIN = 45;
final int SPAWN_INTERVAL_MAX = 100;
final int MAX_ALIENS = 12;

boolean holdLeft = false;
boolean holdRight = false;
boolean holdUp = false;
boolean holdDown = false;
float pushSpeed = 6.0;

int invulnFrames = 0;
final int INVULN_DURATION = 90;
int hitMessageFrames = 0;
String hitMessage = "";

final int STAR_COUNT = 140;
float[] starX = new float[STAR_COUNT];
float[] starY = new float[STAR_COUNT];
float[] starBright = new float[STAR_COUNT];

void setup() {
  size(1280, 800);
  textAlign(CENTER, CENTER);
  imageMode(CENTER);

  imgAlienGreen = loadImage("alien_green.png");
  imgAlienPurple = loadImage("alien_purple.png");
  imgAlienOrange = loadImage("alien_orange.png");
  imgPlayerShip = loadImage("player_ship.png");  // custom ship sprite

  player = new Player(imgPlayerShip);
  scores = new ScoreManager();   // loads highscore.txt
  aliens = new ArrayList<Obstacle>();
  healthPacks = new ArrayList<HealthPack>();
  effects = new ArrayList<GameEntity>();
  bullets = new ArrayList<Bullet>();
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

  for (Obstacle alien : aliens) {
    alien.moveBy(dx, dy);
  }
  for (HealthPack pack : healthPacks) {
    pack.moveBy(dx, dy);
  }
  // Explosions (and any other GameEntity effects) shift with the world
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
  textSize(52);
  text("Don't Crash!!", width / 2, height / 2 - 80);

  textSize(20);
  fill(180);
  text("Star fighter — ship stays centred", width / 2, height / 2 - 20);
  text("Arrows: push world opposite | SPACE: shoot", width / 2, height / 2 + 14);
  text("Phase 8+ — lasers + explosions", width / 2, height / 2 + 46);

  fill(255, 220, 100);
  text("High Score: " + scores.highScore, width / 2, height / 2 + 86);

  fill(180);
  text("Press ENTER to start", width / 2, height / 2 + 126);
}

void drawPlaying() {
  applyArrowPush();
  player.updateFacing(holdLeft, holdRight, holdUp, holdDown);
  player.update();   // GameEntity animation tick
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

  // Polymorphism: Obstacle subclasses via ArrayList<Obstacle>
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

  // Polymorphism: GameEntity effects (explosions) — game keeps running
  for (int i = effects.size() - 1; i >= 0; i--) {
    GameEntity e = effects.get(i);
    e.update();
    if (e.isFinished()) {
      effects.remove(i);
    }
  }

  // Update lasers + bullet-vs-alien hits
  if (fireCooldown > 0) fireCooldown--;
  for (int i = bullets.size() - 1; i >= 0; i--) {
    Bullet b = bullets.get(i);
    b.update();
    if (b.isFinished()) {
      bullets.remove(i);
      continue;
    }
    // Check hit against every alien
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

  if (hitMessageFrames > 60) {
    fill(255, 40, 40, 60);
    rect(0, 0, width, height);
  }

  fill(200);
  textSize(16);
  textAlign(LEFT, TOP);
  text("Lives: " + player.lives, 20, 20);
  text("Score: " + scores.currentScore, 20, 44);
  text("High: " + scores.highScore, 20, 68);
  text("Aliens: " + aliens.size() + " / " + MAX_ALIENS, 20, 92);
  text("SPACE shoot | Green + heal | crash = explosion", 20, 116);
  textAlign(CENTER, CENTER);

  if (hitMessageFrames > 0) {
    fill(255, 220, 80);
    textSize(36);
    text(hitMessage, width / 2, 80);
  }
}

void spawnHealthPack() {
  if (healthPacks.size() >= MAX_HEALTH_PACKS) return;

  float px, py;
  do {
    px = random(80, width - 80);
    py = random(80, height - 80);
  } while (dist(px, py, width / 2.0, height / 2.0) < 180);

  healthPacks.add(new HealthPack(px, py));
}

void handleHealthPickups() {
  for (int i = healthPacks.size() - 1; i >= 0; i--) {
    HealthPack pack = healthPacks.get(i);
    if (!pack.touchesPlayer(player)) continue;

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
  hitMessage = "CRASH! Lives left: " + player.lives;
  println(hitMessage);

  // Phase 8: spawn explosion animation; game continues while it plays
  effects.add(new Explosion(alien.x, alien.y));
  aliens.remove(index);

  if (player.lives <= 0) {
    endRun();
  }
  return true;
}

/** Game over: try to save a new high score to disk. */
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

  fill(0, 0, 0, 160);
  rect(0, 0, width, height);

  fill(255, 80, 80);
  textSize(56);
  text("GAME OVER", width / 2, height / 2 - 70);

  fill(220);
  textSize(24);
  text("Score: " + scores.currentScore, width / 2, height / 2 - 10);
  text("High Score: " + scores.highScore, width / 2, height / 2 + 26);

  if (scores.currentScore >= scores.highScore && scores.currentScore > 0) {
    fill(255, 220, 80);
    text("New record saved to highscore.txt!", width / 2, height / 2 + 64);
  }

  fill(200);
  textSize(20);
  text("Press ENTER to restart", width / 2, height / 2 + 110);
}

void restartGame() {
  player.lives = 3;
  player.facing = -HALF_PI;
  invulnFrames = 0;
  hitMessageFrames = 0;
  hitMessage = "";
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
  println("Restarted — SPACE shooting enabled");
}

/** Fire one laser from the ship nose along current facing. */
void tryFireBullet() {
  if (fireCooldown > 0) return;

  float noseX = player.x + cos(player.facing) * player.bodySize * 0.55;
  float noseY = player.y + sin(player.facing) * player.bodySize * 0.55;
  bullets.add(new Bullet(noseX, noseY, player.facing, BULLET_SPEED));
  fireCooldown = FIRE_COOLDOWN_FRAMES;
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

  // SPACE fires a laser in the facing direction
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
