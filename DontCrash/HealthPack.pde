/**
 * HealthPack — healing pickup (+1 life, capped at 3).
 *
 * After spawning, it does NOT wander by itself.
 * It only shifts when the player pushes the world with arrow keys
 * (same reverse-control model as aliens / stars).
 */
class HealthPack {
  float x;
  float y;
  float size;

  HealthPack(float startX, float startY) {
    x = startX;
    y = startY;
    size = 36;
  }

  void moveBy(float dx, float dy) {
    x += dx;
    y += dy;
  }

  void display() {
    pushMatrix();
    translate(x, y);

    // Soft glow
    noStroke();
    fill(80, 255, 140, 70);
    ellipse(0, 0, size * 1.6, size * 1.6);

    // Green capsule / cross
    fill(40, 200, 100);
    ellipse(0, 0, size, size);
    fill(255);
    rectMode(CENTER);
    rect(0, 0, size * 0.22, size * 0.7, 3);
    rect(0, 0, size * 0.7, size * 0.22, 3);
    rectMode(CORNER);

    popMatrix();
  }

  boolean touchesPlayer(Player p) {
    float distance = dist(x, y, p.x, p.y);
    return distance < (size * 0.45 + p.getCollisionRadius());
  }

  boolean isOffScreen() {
    float margin = size + 120;
    return (x < -margin || x > width + margin ||
            y < -margin || y > height + margin);
  }
}
