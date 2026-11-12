/**
 * DontCrash.pde — Main sketch for Don't Crash!!
 * Owns game states, input, spawning, collisions, HUD, and list cleanup.
 * Scheme A: ship stays centred; arrow keys push the world the other way.
 */

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
PImage[] explosionFrames;
PImage[] alienAnimFrames;
PImage[] flameFrames;

int framesUntilSpawn = 0;
final int SPAWN_INTERVAL_MIN = 45;
final int SPAWN_INTERVAL_MAX = 100;
final int MAX_ALIENS = 12;

boolean holdLeft = false;
boolean holdRight = false;
boolean holdUp = false;
boolean holdDown = false;
boolean holdSpace = false;
int lastArrowKey = UP;
float pushSpeed = 6.0;

int invulnFrames = 0;
final int INVULN_DURATION = 90;
int hitMessageFrames = 0;
String hitMessage = "";
int hitMsgR = 255;
int hitMsgG = 220;
int hitMsgB = 80;
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
  // Four facing sprites prepared offline (no rotate() at runtime)
  imgShipUp = loadImage("player_ship_up.png");
  imgShipDown = loadImage("player_ship_down.png");
  imgShipLeft = loadImage("player_ship_left.png");
  imgShipRight = loadImage("player_ship_right.png");

  // PImage animation sequences (70–80% / 80%+)
  explosionFrames = new PImage[5];
  for (int i = 0; i < explosionFrames.length; i++) {
    explosionFrames[i] = loadImage("explosion_" + i + ".png");
  }
  alienAnimFrames = new PImage[3];
  for (int i = 0; i < alienAnimFrames.length; i++) {
    alienAnimFrames[i] = loadImage("alien_anim_" + i + ".png");
  }
  flameFrames = new PImage[4];
  for (int i = 0; i < flameFrames.length; i++) {
    flameFrames[i] = loadImage("flame_" + i + ".png");
  }

  player = new Player(imgShipUp, imgShipDown, imgShipLeft, imgShipRight);
  player.setFlameFrames(flameFrames);
  scores = new ScoreManager();
  aliens = new ArrayList<Obstacle>();
  healthPacks = new ArrayList<HealthPack>();
  effects = new ArrayList<GameEntity>();
  bullets = new ArrayList<Bullet>();
  initStarfield();
}

void draw() {
  // Solid flash backgrounds (no alpha fill)
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

// Push the whole world opposite to the held arrow keys
void applyArrowPush() {
  float dx = 0;
  float dy = 0;

  if (holdLeft)  dx = dx + pushSpeed;
  if (holdRight) dx = dx - pushSpeed;
  if (holdUp)    dy = dy + pushSpeed;
  if (holdDown)  dy = dy - pushSpeed;

  syncShipFacingToKeys();

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
  text("Don't Crash!!", width / 2, height / 2 - 90);

  fill(200);
  textSize(20);
  text("Arrow keys: push the world (ship stays in the centre)", width / 2, height / 2 - 10);
  text("SPACE: fire lasers", width / 2, height / 2 + 24);
  text("3 lives — level rises with your score", width / 2, height / 2 + 58);

  textSize(22);
  fill(180);
  text("Press ENTER to start", width / 2, height / 2 + 110);
}

void drawPlaying() {
  applyArrowPush();
  player.update();
  scores.updateSurvivalScore();

  updateAlienSpawning();
  updateHealthSpawning();

  updateAliens(aliens);
  updateHealthPacks(healthPacks);
  updateEffects(effects);

  if (fireCooldown > 0) {
    fireCooldown = fireCooldown - 1;
  }
  if (holdSpace) {
    tryFireBullet();
  }
  updateBullets(bullets, aliens);

  if (invulnFrames > 0) invulnFrames--;
  if (hitMessageFrames > 0) hitMessageFrames--;
  if (healFlashFrames > 0) healFlashFrames--;
  if (crashFlashFrames > 0) crashFlashFrames--;

  handleHealthPickups(healthPacks);

  if (invulnFrames <= 0) {
    handlePlayerAlienCollisions(aliens);
  }

  // Mark first, remove once at the end of the frame
  removeDeadAliens(aliens);
  removeFinishedBullets(bullets);
  removeFinishedHealthPacks(healthPacks);
  removeFinishedEffects(effects);

  drawStarfield();
  drawWorldEntities(healthPacks, aliens, bullets, effects);

  if (invulnFrames <= 0 || (frameCount / 4) % 2 == 0) {
    player.display();
  }

  drawHud(player, scores);
}

// Higher level → shorter spawn interval
void updateAlienSpawning() {
  framesUntilSpawn--;
  if (framesUntilSpawn > 0) return;

  spawnAlienAtEdge();

  int spawnMin = SPAWN_INTERVAL_MIN;
  int spawnMax = SPAWN_INTERVAL_MAX;
  int level = scores.getLevel();

  if (level >= 2) {
    spawnMin = 35;
    spawnMax = 80;
  }
  if (level >= 3) {
    spawnMin = 25;
    spawnMax = 60;
  }
  if (level >= 4) {
    spawnMin = 18;
    spawnMax = 45;
  }

  framesUntilSpawn = int(random(spawnMin, spawnMax));
}

void updateHealthSpawning() {
  framesUntilHealthSpawn--;
  if (framesUntilHealthSpawn <= 0) {
    spawnHealthPack();
    framesUntilHealthSpawn = int(random(HEALTH_SPAWN_MIN, HEALTH_SPAWN_MAX));
  }
}

void updateAliens(ArrayList<Obstacle> list) {
  for (int i = 0; i < list.size(); i++) {
    Obstacle alien = list.get(i);
    if (alien.isDead()) continue;
    alien.update();
    if (alien.isOffScreen()) {
      alien.markDead();
    }
  }
}

void updateHealthPacks(ArrayList<HealthPack> list) {
  for (int i = 0; i < list.size(); i++) {
    HealthPack pack = list.get(i);
    if (pack.isDead()) continue;
    pack.update();
    if (pack.isOffScreen()) {
      pack.markDead();
    }
  }
}

void updateEffects(ArrayList<GameEntity> list) {
  for (int i = 0; i < list.size(); i++) {
    GameEntity e = list.get(i);
    if (e.isFinished()) continue;
    e.update();
  }
}

// Hit detection only marks entities; removal happens later
void updateBullets(ArrayList<Bullet> bulletList, ArrayList<Obstacle> alienList) {
  for (int i = 0; i < bulletList.size(); i++) {
    Bullet b = bulletList.get(i);
    if (b.isFinished()) continue;

    b.update();

    for (int j = 0; j < alienList.size(); j++) {
      Obstacle alien = alienList.get(j);
      if (alien.isDead()) continue;

      if (b.hits(alien)) {
        effects.add(new Explosion(alien.x, alien.y, explosionFrames));
        scores.addBonus(10);
        showHitMessage("Score +10", 255, 220, 80, 45);
        alien.markDead();
        b.markDead();
        break;
      }
    }
  }
}

void removeDeadAliens(ArrayList<Obstacle> list) {
  for (int i = list.size() - 1; i >= 0; i--) {
    if (list.get(i).isDead()) {
      list.remove(i);
    }
  }
}

void removeFinishedBullets(ArrayList<Bullet> list) {
  for (int i = list.size() - 1; i >= 0; i--) {
    if (list.get(i).isFinished()) {
      list.remove(i);
    }
  }
}

void removeFinishedHealthPacks(ArrayList<HealthPack> list) {
  for (int i = list.size() - 1; i >= 0; i--) {
    if (list.get(i).isFinished()) {
      list.remove(i);
    }
  }
}

void removeFinishedEffects(ArrayList<GameEntity> list) {
  for (int i = list.size() - 1; i >= 0; i--) {
    if (list.get(i).isFinished()) {
      list.remove(i);
    }
  }
}

void drawWorldEntities(ArrayList<HealthPack> packs,
                       ArrayList<Obstacle> alienList,
                       ArrayList<Bullet> bulletList,
                       ArrayList<GameEntity> effectList) {
  for (HealthPack pack : packs) {
    pack.display();
  }
  for (Obstacle alien : alienList) {
    alien.display();
  }
  for (Bullet b : bulletList) {
    b.display();
  }
  for (GameEntity e : effectList) {
    e.display();
  }
}

void drawHud(Player p, ScoreManager s) {
  fill(200);
  textSize(16);
  textAlign(LEFT, TOP);
  text("Lives: " + p.getLives(), 20, 20);
  text("Score: " + s.getCurrentScore(), 20, 44);
  text("Level: " + s.getLevel(), 20, 68);
  text("High: " + s.getHighScore(), 20, 92);
  textAlign(CENTER, CENTER);

  if (hitMessageFrames > 0) {
    fill(hitMsgR, hitMsgG, hitMsgB);
    textSize(36);
    text(hitMessage, width / 2, 80);
  }
}

void showHitMessage(String msg, int r, int g, int b, int frames) {
  hitMessage = msg;
  hitMsgR = r;
  hitMsgG = g;
  hitMsgB = b;
  hitMessageFrames = frames;
}

void spawnHealthPack() {
  if (healthPacks.size() >= MAX_HEALTH_PACKS) return;

  float px = random(80, width - 80);
  float py = random(80, height - 80);

  // Keep pickups away from the ship spawn point
  int tries = 0;
  while (dist(px, py, width / 2.0, height / 2.0) < 180 && tries < 30) {
    px = random(80, width - 80);
    py = random(80, height - 80);
    tries++;
  }

  healthPacks.add(new HealthPack(px, py));
}

void handleHealthPickups(ArrayList<HealthPack> list) {
  for (int i = 0; i < list.size(); i++) {
    HealthPack pack = list.get(i);
    if (pack.isDead()) continue;
    if (!pack.touchesPlayer(player)) continue;

    healFlashFrames = 45;

    if (player.heal(1)) {
      scores.addBonus(5);
      showHitMessage("+1 Life  (" + player.getLives() + "/3)", 80, 255, 140, 70);
    } else {
      showHitMessage("Lives Full (3/3)", 180, 220, 180, 55);
    }
    pack.markDead();
  }
}

void spawnAlienAtEdge() {
  int maxAliens = MAX_ALIENS;
  if (scores.getLevel() >= 3) {
    maxAliens = MAX_ALIENS + 2;
  }
  if (aliens.size() >= maxAliens) return;

  float sz = random(28, 42);
  float roll = random(1);
  Obstacle alien;
  float speedBoost = 1.0 + (scores.getLevel() - 1) * 0.15;

  if (roll < 0.35) {
    alien = new FastObstacle(0, 0, sz * 0.9, imgAlienOrange);
  } else if (roll < 0.65) {
    alien = new MovingObstacle(0, 0, sz, imgAlienPurple);
  } else {
    alien = new Obstacle(0, 0, sz, random(1.6, 3.0) * speedBoost,
                         color(120, 220, 120), imgAlienGreen);
    alien.setAnimFrames(alienAnimFrames);
  }

  alien.respawnAtEdge();
  aliens.add(alien);
}

void handlePlayerAlienCollisions(ArrayList<Obstacle> list) {
  for (int i = 0; i < list.size(); i++) {
    Obstacle alien = list.get(i);
    if (alien.isDead()) continue;
    if (!player.checkCollision(alien)) continue;

    player.loseLife();
    invulnFrames = INVULN_DURATION;
    crashFlashFrames = 20;
    showHitMessage("-1 Life  (" + player.getLives() + "/3)", 255, 90, 90, 80);
    println(hitMessage);

    effects.add(new Explosion(alien.x, alien.y, explosionFrames));
    alien.markDead();

    if (player.getLives() <= 0) {
      endRun();
    }
    return;
  }
}

void endRun() {
  gameState = STATE_GAME_OVER;
  clearHoldKeys();
  scores.saveHighScore();
  println("GAME OVER — score=" + scores.getCurrentScore() +
          " high=" + scores.getHighScore());
}

// Starfield + result text only
void drawGameOver() {
  drawStarfield();

  fill(255, 80, 80);
  textSize(56);
  text("GAME OVER", width / 2, height / 2 - 70);

  fill(220);
  textSize(24);
  text("Score: " + scores.getCurrentScore(), width / 2, height / 2 - 10);
  text("High Score: " + scores.getHighScore(), width / 2, height / 2 + 26);

  if (scores.getCurrentScore() >= scores.getHighScore() &&
      scores.getCurrentScore() > 0) {
    fill(255, 220, 80);
    text("New record this run!", width / 2, height / 2 + 64);
  }

  fill(200);
  textSize(20);
  text("Press ENTER to restart", width / 2, height / 2 + 110);
}

void restartGame() {
  player.resetForNewRun();
  invulnFrames = 0;
  hitMessageFrames = 0;
  hitMessage = "";
  hitMsgR = 255;
  hitMsgG = 220;
  hitMsgB = 80;
  healFlashFrames = 0;
  crashFlashFrames = 0;
  clearHoldKeys();
  scores.resetRun();

  aliens.clear();
  healthPacks.clear();
  effects.clear();
  bullets.clear();
  fireCooldown = 0;

  Obstacle a1 = new Obstacle(180, 140, 36, 2.2, color(120, 220, 120), imgAlienGreen);
  a1.setAnimFrames(alienAnimFrames);
  a1.placeOnScreen(180, 140);
  aliens.add(a1);

  FastObstacle a2 = new FastObstacle(width - 200, 160, 32, imgAlienOrange);
  a2.placeOnScreen(width - 200, 160);
  aliens.add(a2);

  MovingObstacle a3 = new MovingObstacle(width / 2, height - 140, 38, imgAlienPurple);
  a3.placeOnScreen(width / 2, height - 140);
  aliens.add(a3);

  healthPacks.add(new HealthPack(220, height - 180));

  framesUntilSpawn = SPAWN_INTERVAL_MIN;
  framesUntilHealthSpawn = HEALTH_SPAWN_MIN;
  gameState = STATE_PLAYING;
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

// Prefer the most recently pressed arrow that is still held
void syncShipFacingToKeys() {
  if (lastArrowKey == LEFT && holdLeft) {
    player.setFacingFromKey(player.DIR_LEFT);
    return;
  }
  if (lastArrowKey == RIGHT && holdRight) {
    player.setFacingFromKey(player.DIR_RIGHT);
    return;
  }
  if (lastArrowKey == UP && holdUp) {
    player.setFacingFromKey(player.DIR_UP);
    return;
  }
  if (lastArrowKey == DOWN && holdDown) {
    player.setFacingFromKey(player.DIR_DOWN);
    return;
  }

  if (holdLeft) {
    lastArrowKey = LEFT;
    player.setFacingFromKey(player.DIR_LEFT);
  } else if (holdRight) {
    lastArrowKey = RIGHT;
    player.setFacingFromKey(player.DIR_RIGHT);
  } else if (holdUp) {
    lastArrowKey = UP;
    player.setFacingFromKey(player.DIR_UP);
  } else if (holdDown) {
    lastArrowKey = DOWN;
    player.setFacingFromKey(player.DIR_DOWN);
  }
}

void keyPressed() {
  if ((gameState == STATE_START || gameState == STATE_GAME_OVER) &&
      (key == ENTER || key == RETURN)) {
    restartGame();
    return;
  }

  if (gameState != STATE_PLAYING) return;

  if (keyCode == LEFT) {
    holdLeft = true;
    lastArrowKey = LEFT;
    player.setFacingFromKey(player.DIR_LEFT);
  } else if (keyCode == RIGHT) {
    holdRight = true;
    lastArrowKey = RIGHT;
    player.setFacingFromKey(player.DIR_RIGHT);
  } else if (keyCode == UP) {
    holdUp = true;
    lastArrowKey = UP;
    player.setFacingFromKey(player.DIR_UP);
  } else if (keyCode == DOWN) {
    holdDown = true;
    lastArrowKey = DOWN;
    player.setFacingFromKey(player.DIR_DOWN);
  }

  if (key == ' ') {
    holdSpace = true;
  }
}

void keyReleased() {
  if (keyCode == LEFT)  holdLeft = false;
  if (keyCode == RIGHT) holdRight = false;
  if (keyCode == UP)    holdUp = false;
  if (keyCode == DOWN)  holdDown = false;
  if (key == ' ') {
    holdSpace = false;
  }
  syncShipFacingToKeys();
}

void clearHoldKeys() {
  holdLeft = false;
  holdRight = false;
  holdUp = false;
  holdDown = false;
  holdSpace = false;
  lastArrowKey = UP;
}
