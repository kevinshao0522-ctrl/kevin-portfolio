/**
 * Player — the player's spaceship.
 *
 * Stays FIXED at the screen centre.
 * Uses PImage sprite (data/player_ship.png) when available.
 */
class Player implements GameEntity {
  float x;
  float y;
  float bodySize;
  int lives;
  float facing;
  PImage sprite;   // custom ship art

  // Animation: 4 engine frames, advanced every few draw cycles
  int animFrame;
  int animTimer;
  final int ANIM_SPEED = 5;   // frames of draw() per animation step
  final int ANIM_COUNT = 4;

  Player() {
    this(null);
  }

  Player(PImage shipImage) {
    x = width / 2.0;
    y = height / 2.0;
    bodySize = 72;          // a bit larger to show the detailed sprite
    lives = 3;
    facing = -HALF_PI;
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
    // Art points "up"; rotate so nose matches facing.
    rotate(facing + HALF_PI);

    // Animated engine exhaust drawn BEHIND the sprite
    float flameLen = 12 + animFrame * 6;
    float flameAlpha = 160 + animFrame * 20;
    noStroke();
    fill(255, 160, 40, flameAlpha);
    ellipse(-bodySize * 0.12, bodySize * 0.42 + flameLen * 0.2, 10, flameLen);
    ellipse(bodySize * 0.12, bodySize * 0.42 + flameLen * 0.2, 10, flameLen);
    fill(255, 230, 120, flameAlpha);
    ellipse(-bodySize * 0.12, bodySize * 0.42, 6, flameLen * 0.45);
    ellipse(bodySize * 0.12, bodySize * 0.42, 6, flameLen * 0.45);

    if (sprite != null) {
      imageMode(CENTER);
      // Keep aspect: sprite is taller than wide
      float drawH = bodySize * 1.35;
      float drawW = drawH * (sprite.width / float(sprite.height));
      image(sprite, 0, 0, drawW, drawH);
    } else {
      // Fallback geometric ship if image missing
      fill(180, 210, 255);
      triangle(0, -bodySize * 0.7,
               -bodySize * 0.55, bodySize * 0.55,
               bodySize * 0.55, bodySize * 0.55);
      fill(80, 160, 255);
      ellipse(0, 0, bodySize * 0.35, bodySize * 0.35);
    }

    popMatrix();
  }
}
