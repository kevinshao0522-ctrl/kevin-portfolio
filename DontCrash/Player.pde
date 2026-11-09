/**
 * Player — the player's spaceship.
 *
 * Stays FIXED at the screen centre.
 * Implements GameEntity so most entities share one polymorphic API (Phase 8).
 */
class Player implements GameEntity {
  float x;
  float y;
  float bodySize;
  int lives;
  float facing;

  // Animation: 4 engine frames, advanced every few draw cycles
  int animFrame;
  int animTimer;
  final int ANIM_SPEED = 5;   // frames of draw() per animation step
  final int ANIM_COUNT = 4;

  Player() {
    x = width / 2.0;
    y = height / 2.0;
    bodySize = 48;
    lives = 3;
    facing = -HALF_PI;
    animFrame = 0;
    animTimer = 0;
  }

  float getCollisionRadius() {
    return bodySize * 0.45;
  }

  boolean checkCollision(Obstacle obstacle) {
    float distance = dist(x, y, obstacle.x, obstacle.y);
    float minDist = getCollisionRadius() + obstacle.getCollisionRadius();
    return distance < minDist;
  }

  boolean heal(int amount) {
    if (lives >= 3) return false;
    lives = min(3, lives + amount);
    return true;
  }

  void updateFacing(boolean left, boolean right, boolean up, boolean down) {
    float dx = 0;
    float dy = 0;
    if (left)  dx -= 1;
    if (right) dx += 1;
    if (up)    dy -= 1;
    if (down)  dy += 1;
    if (dx != 0 || dy != 0) {
      facing = atan2(dy, dx);
    }
  }

  /** GameEntity.update — advance facing-independent animation. */
  void update() {
    updateAnimation();
  }

  /** Advance the engine flame animation sequence. */
  void updateAnimation() {
    animTimer++;
    if (animTimer >= ANIM_SPEED) {
      animTimer = 0;
      animFrame = (animFrame + 1) % ANIM_COUNT;
    }
  }

  void moveBy(float dx, float dy) {
    // Ship stays centred — intentionally ignore world push.
  }

  boolean isFinished() {
    return false;
  }

  void display() {
    pushMatrix();
    translate(x, y);
    rotate(facing + HALF_PI);

    noStroke();
    fill(180, 210, 255);
    triangle(0, -bodySize * 0.7,
             -bodySize * 0.55, bodySize * 0.55,
             bodySize * 0.55, bodySize * 0.55);

    fill(80, 160, 255);
    ellipse(0, 0, bodySize * 0.35, bodySize * 0.35);

    // Animated engine exhaust — length/brightness changes by animFrame
    float flameLen = 10 + animFrame * 5;
    float flameAlpha = 160 + animFrame * 20;
    fill(255, 160, 40, flameAlpha);
    ellipse(-bodySize * 0.2, bodySize * 0.55 + flameLen * 0.15, 8, flameLen);
    ellipse(bodySize * 0.2, bodySize * 0.55 + flameLen * 0.15, 8, flameLen);
    fill(255, 230, 120, flameAlpha);
    ellipse(-bodySize * 0.2, bodySize * 0.55, 5, flameLen * 0.5);
    ellipse(bodySize * 0.2, bodySize * 0.55, 5, flameLen * 0.5);

    fill(255, 255, 120);
    ellipse(0, -bodySize * 0.55, 8, 8);

    popMatrix();
  }
}
