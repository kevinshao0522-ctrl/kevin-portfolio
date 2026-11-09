/**
 * Obstacle — base class for aliens / hazards.
 *
 * In Scheme A these are alien ships that approach the player.
 * Phase 2: store position/size and draw at least two instances.
 * Phase 3: move opposite to arrow keys.
 * Phase 6+: subclasses (FastObstacle, etc.) will inherit from this class.
 */
class Obstacle {
  float x;
  float y;
  float size;
  float speed;   // used from Phase 3 for independent / keyboard movement
  color bodyColor;

  /**
   * Create an alien at a given position.
   */
  Obstacle(float startX, float startY, float obstacleSize, float moveSpeed, color c) {
    x = startX;
    y = startY;
    size = obstacleSize;
    speed = moveSpeed;
    bodyColor = c;
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
   * Move by a delta. Phase 3 will call this when arrow keys are held,
   * using the OPPOSITE direction to the key pressed.
   */
  void moveBy(float dx, float dy) {
    x += dx;
    y += dy;
  }

  /**
   * True when the alien is far outside the visible window.
   * Used later to remove unused objects (Phase 5).
   */
  boolean isOffScreen() {
    float margin = size;
    return (x < -margin || x > width + margin ||
            y < -margin || y > height + margin);
  }
}
