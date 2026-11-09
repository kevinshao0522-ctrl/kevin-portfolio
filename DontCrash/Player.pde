/**
 * Player — spaceship fixed at screen centre.
 * Facing uses four discrete directions (no atan2 / rotate).
 */
class Player implements GameEntity {
  // Direction constants
  final int DIR_UP = 0;
  final int DIR_RIGHT = 1;
  final int DIR_DOWN = 2;
  final int DIR_LEFT = 3;

  float x;
  float y;
  float bodySize;
  int lives;
  int facing;       // one of DIR_UP / RIGHT / DOWN / LEFT
  PImage sprite;

  int animFrame;
  int animTimer;
  final int ANIM_SPEED = 5;
  final int ANIM_COUNT = 4;

  Player() {
    this(null);
  }

  Player(PImage shipImage) {
    x = width / 2.0;
    y = height / 2.0;
    bodySize = 72;
    lives = 3;
    facing = DIR_UP;
    animFrame = 0;
    animTimer = 0;
    sprite = shipImage;
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

  /** Set facing from held arrow keys (discrete 4-way). */
  void updateFacing(boolean left, boolean right, boolean up, boolean down) {
    if (left)  facing = DIR_LEFT;
    if (right) facing = DIR_RIGHT;
    if (up)    facing = DIR_UP;
    if (down)  facing = DIR_DOWN;
  }

  /** Bullet velocity for current facing (no trig). */
  float getBulletVx(float speed) {
    if (facing == DIR_LEFT)  return -speed;
    if (facing == DIR_RIGHT) return speed;
    return 0;
  }

  float getBulletVy(float speed) {
    if (facing == DIR_UP)   return -speed;
    if (facing == DIR_DOWN) return speed;
    return 0;
  }

  /** Nose offset for spawning bullets (no trig). */
  float getNoseX() {
    if (facing == DIR_LEFT)  return x - bodySize * 0.55;
    if (facing == DIR_RIGHT) return x + bodySize * 0.55;
    return x;
  }

  float getNoseY() {
    if (facing == DIR_UP)   return y - bodySize * 0.55;
    if (facing == DIR_DOWN) return y + bodySize * 0.55;
    return y;
  }

  void update() {
    updateAnimation();
  }

  void updateAnimation() {
    animTimer++;
    if (animTimer >= ANIM_SPEED) {
      animTimer = 0;
      animFrame = (animFrame + 1) % ANIM_COUNT;
    }
  }

  void moveBy(float dx, float dy) {
    // Ship stays centred.
  }

  boolean isFinished() {
    return false;
  }

  void display() {
    float flameLen = 12 + animFrame * 6;
    noStroke();

    // Engine flame behind ship (position depends on facing)
    fill(255, 160, 40);
    if (facing == DIR_UP) {
      ellipse(x - bodySize * 0.12, y + bodySize * 0.42 + flameLen * 0.2, 10, flameLen);
      ellipse(x + bodySize * 0.12, y + bodySize * 0.42 + flameLen * 0.2, 10, flameLen);
    } else if (facing == DIR_DOWN) {
      ellipse(x - bodySize * 0.12, y - bodySize * 0.42 - flameLen * 0.2, 10, flameLen);
      ellipse(x + bodySize * 0.12, y - bodySize * 0.42 - flameLen * 0.2, 10, flameLen);
    } else if (facing == DIR_LEFT) {
      ellipse(x + bodySize * 0.42 + flameLen * 0.2, y - bodySize * 0.12, flameLen, 10);
      ellipse(x + bodySize * 0.42 + flameLen * 0.2, y + bodySize * 0.12, flameLen, 10);
    } else {
      ellipse(x - bodySize * 0.42 - flameLen * 0.2, y - bodySize * 0.12, flameLen, 10);
      ellipse(x - bodySize * 0.42 - flameLen * 0.2, y + bodySize * 0.12, flameLen, 10);
    }

    float drawH = bodySize * 1.35;
    float drawW = drawH;
    if (sprite != null) {
      drawW = drawH * (sprite.width / float(sprite.height));
    }

    // Draw ship without rotate: for left/right use swapped width/height look via geometry
    if (sprite != null) {
      // Always draw upright sprite; facing shown by flame + bullet direction
      // (avoids rotate). Image drawn from top-left using default imageMode.
      image(sprite, x - drawW / 2, y - drawH / 2, drawW, drawH);
    } else {
      fill(180, 210, 255);
      if (facing == DIR_UP) {
        triangle(x, y - bodySize * 0.7,
                 x - bodySize * 0.55, y + bodySize * 0.55,
                 x + bodySize * 0.55, y + bodySize * 0.55);
      } else if (facing == DIR_DOWN) {
        triangle(x, y + bodySize * 0.7,
                 x - bodySize * 0.55, y - bodySize * 0.55,
                 x + bodySize * 0.55, y - bodySize * 0.55);
      } else if (facing == DIR_LEFT) {
        triangle(x - bodySize * 0.7, y,
                 x + bodySize * 0.55, y - bodySize * 0.55,
                 x + bodySize * 0.55, y + bodySize * 0.55);
      } else {
        triangle(x + bodySize * 0.7, y,
                 x - bodySize * 0.55, y - bodySize * 0.55,
                 x - bodySize * 0.55, y + bodySize * 0.55);
      }
      fill(80, 160, 255);
      ellipse(x, y, bodySize * 0.35, bodySize * 0.35);
    }
  }
}
