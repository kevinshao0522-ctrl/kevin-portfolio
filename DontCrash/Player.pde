/**
 * Player — the player's spaceship.
 *
 * Stays FIXED at the screen centre.
 * Phase 6: appearance (facing angle / look) changes with arrow keys.
 */
class Player {
  float x;
  float y;
  float bodySize;
  int lives;

  // Facing angle in radians.  -HALF_PI = nose up (default).
  float facing;

  Player() {
    x = width / 2.0;
    y = height / 2.0;
    bodySize = 48;
    lives = 3;
    facing = -HALF_PI;
  }

  float getCollisionRadius() {
    return bodySize * 0.45;
  }

  boolean checkCollision(Obstacle obstacle) {
    float distance = dist(x, y, obstacle.x, obstacle.y);
    float minDist = getCollisionRadius() + obstacle.getCollisionRadius();
    return distance < minDist;
  }

  /**
   * Update ship facing from held arrow keys.
   * Even though the ship does not translate, its nose turns
   * toward the direction the player is "flying".
   */
  void updateFacing(boolean left, boolean right, boolean up, boolean down) {
    float dx = 0;
    float dy = 0;
    if (left)  dx -= 1;
    if (right) dx += 1;
    if (up)    dy -= 1;
    if (down)  dy += 1;

    // Only change facing when at least one arrow is held
    if (dx != 0 || dy != 0) {
      facing = atan2(dy, dx);
    }
  }

  void display() {
    pushMatrix();
    translate(x, y);
    // Triangle art points "up" (-Y). Rotate so nose matches facing.
    rotate(facing + HALF_PI);

    noStroke();
    // Body colour shifts slightly with direction for clearer feedback
    fill(180, 210, 255);
    triangle(0, -bodySize * 0.7,
             -bodySize * 0.55, bodySize * 0.55,
             bodySize * 0.55, bodySize * 0.55);

    fill(80, 160, 255);
    ellipse(0, 0, bodySize * 0.35, bodySize * 0.35);

    // Engine glow at the rear
    fill(255, 140, 40);
    ellipse(-bodySize * 0.2, bodySize * 0.55, 8, 12);
    ellipse(bodySize * 0.2, bodySize * 0.55, 8, 12);

    // Direction tip light
    fill(255, 255, 120);
    ellipse(0, -bodySize * 0.55, 8, 8);

    popMatrix();
  }
}
