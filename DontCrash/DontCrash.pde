/**
 * Don't Crash!! — Star Wars theme (Scheme A)
 *
 * Movement model:
 * - Player ship stays at the centre forever.
 * - Aliens drift on their own (Phase 2).
 * - Arrow keys ADD opposite push to aliens + starfield (Phase 3),
 *   so it FEELS like the ship is flying.
 *
 * Controls (assignment rule):
 * LEFT  -> world moves RIGHT
 * RIGHT -> world moves LEFT
 * UP    -> world moves DOWN
 * DOWN  -> world moves UP
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
// true while the matching arrow key is held down
boolean holdLeft = false;
boolean holdRight = false;
boolean holdUp = false;
boolean holdDown = false;

// How fast aliens + stars shift when an arrow key is held
float pushSpeed = 6.0;

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
      // Phase 4+
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

/**
 * Shift every star by (dx, dy) and wrap around the screen edges
 * so the starfield feels endless while the ship stays centred.
 */
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

/**
 * Read held arrow keys and return the OPPOSITE world push.
 * Example: holding LEFT means the world (aliens/stars) should move RIGHT.
 */
void applyArrowPush() {
  float dx = 0;
  float dy = 0;

  if (holdLeft)  dx += pushSpeed;   // LEFT key  -> world moves right
  if (holdRight) dx -= pushSpeed;   // RIGHT key -> world moves left
  if (holdUp)    dy += pushSpeed;   // UP key    -> world moves down
  if (holdDown)  dy -= pushSpeed;   // DOWN key  -> world moves up

  if (dx == 0 && dy == 0) return;

  // Push every alien the same way (assignment: all obstacles move together)
  alien1.moveBy(dx, dy);
  alien2.moveBy(dx, dy);

  // Scroll background the same direction for the "I am flying" illusion
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
  text("Phase 3 — keyboard reverse controls", width / 2, height / 2 + 58);
  text("Press ENTER to start", width / 2, height / 2 + 96);
}

void drawPlaying() {
  // 1) Player keyboard push (opposite direction)
  applyArrowPush();

  // 2) Aliens still wander on their own
  alien1.update();
  alien2.update();

  // 3) Draw world
  drawStarfield();
  alien1.display();
  alien2.display();
  player.display();

  // HUD
  fill(200);
  textSize(16);
  textAlign(LEFT, TOP);
  text("Lives: " + player.lives, 20, 20);
  text("Arrows: push world opposite | Ship stays centre", 20, 44);
  textAlign(CENTER, CENTER);
}

void keyPressed() {
  if (gameState == STATE_START && (key == ENTER || key == RETURN)) {
    gameState = STATE_PLAYING;
    println("Entered PLAYING — Phase 3: reverse arrow controls active");
    return;
  }

  if (gameState != STATE_PLAYING) return;

  // keyCode is used for special keys like arrows
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
