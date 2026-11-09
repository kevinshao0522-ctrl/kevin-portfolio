/**
 * Obstacle — base class for aliens / hazards.
 *
 * Scheme A: alien ships that keep moving on their own (even with no key input).
 * Phase 3 will ADD keyboard push (opposite to arrow keys) on top of this drift.
 * Phase 6+: subclasses (FastObstacle, etc.) will inherit from this class.
 */
class Obstacle {
  float x;
  float y;
  float size;
  float speed;      // how fast this alien drifts each frame
  float vx;         // independent velocity X
  float vy;         // independent velocity Y
  color bodyColor;

  /**
   * Create an alien at a given position.
   * It immediately aims roughly toward the screen centre (where the player is).
   */
  Obstacle(float startX, float startY, float obstacleSize, float moveSpeed, color c) {
    x = startX;
    y = startY;
    size = obstacleSize;
    speed = moveSpeed;
    bodyColor = c;
    aimTowardCenter();
  }

  /** Set velocity so the alien flies toward the canvas centre. */
  void aimTowardCenter() {
    float cx = width / 2.0;
    float cy = height / 2.0;
    float angle = atan2(cy - y, cx - x);
    // Small random wobble so two aliens do not share one perfect line
    angle += random(-0.35, 0.35);
    vx = cos(angle) * speed;
    vy = sin(angle) * speed;
  }

  /**
   * Called every frame: aliens move by themselves (no player input needed).
   * If they leave the screen, respawn from a random edge and aim inward again.
   */
  void update() {
    x += vx;
    y += vy;

    if (isOffScreen()) {
      respawnAtEdge();
    }
  }

  /** Place the alien just outside one random edge of the window. */
  void respawnAtEdge() {
    int side = int(random(4)); // 0=left, 1=right, 2=top, 3=bottom
    float margin = size + 10;

    if (side == 0) {
      x = -margin;
      y = random(height);
    } else if (side == 1) {
      x = width + margin;
      y = random(height);
    } else if (side == 2) {
      x = random(width);
      y = -margin;
    } else {
      x = random(width);
      y = height + margin;
    }

    aimTowardCenter();
  }

  /**
   * Draw a simple alien (oval body + eyes).
   * Images (PImage) come in a later band; shapes are enough for Phase 2.
   */
  void display() {
    pushMatrix();
    translate(x, y);

    noStroke();
    fill(bodyColor);
    ellipse(0, 0, size, size * 0.75);

    // Eyes
    fill(255);
    ellipse(-size * 0.18, -size * 0.05, size * 0.22, size * 0.28);
    ellipse(size * 0.18, -size * 0.05, size * 0.22, size * 0.28);
    fill(20);
    ellipse(-size * 0.18, -size * 0.05, size * 0.1, size * 0.14);
    ellipse(size * 0.18, -size * 0.05, size * 0.1, size * 0.14);

    // Antenna
    stroke(bodyColor);
    strokeWeight(2);
    line(-size * 0.15, -size * 0.35, -size * 0.25, -size * 0.55);
    line(size * 0.15, -size * 0.35, size * 0.25, -size * 0.55);
    noStroke();
    fill(255, 80, 80);
    ellipse(-size * 0.25, -size * 0.55, 6, 6);
    ellipse(size * 0.25, -size * 0.55, 6, 6);

    popMatrix();
  }

  /**
   * Extra shift from keyboard (Phase 3).
   * Independent vx/vy still apply every frame in update().
   */
  void moveBy(float dx, float dy) {
    x += dx;
    y += dy;
  }

  /**
   * True when the alien is far outside the visible window.
   */
  boolean isOffScreen() {
    float margin = size;
    return (x < -margin || x > width + margin ||
            y < -margin || y > height + margin);
  }
}
