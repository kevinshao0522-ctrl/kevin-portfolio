/**
 * HealthPack.pde — Stationary heal pickup (+1 life, capped at 3).
 * Marked finished first; removed later by the main play loop.
 */
class HealthPack extends WorldObject {
  float drawSize;
  private boolean dead;

  HealthPack(float startX, float startY) {
    super(startX, startY, 36);
    drawSize = 36;
    dead = false;
  }

  void markDead() {
    dead = true;
  }

  boolean isDead() {
    return dead;
  }

  boolean isFinished() {
    return dead;
  }

  void update() {
    // Simple two-frame size pulse
    if ((frameCount / 12) % 2 == 0) {
      drawSize = size;
    } else {
      drawSize = size + 4;
    }
  }

  void display() {
    noStroke();
    fill(80, 255, 140);
    ellipse(x, y, drawSize * 1.6, drawSize * 1.6);
    fill(40, 200, 100);
    ellipse(x, y, drawSize, drawSize);
    fill(255);
    rect(x - drawSize * 0.11, y - drawSize * 0.35, drawSize * 0.22, drawSize * 0.7);
    rect(x - drawSize * 0.35, y - drawSize * 0.11, drawSize * 0.7, drawSize * 0.22);
  }

  boolean touchesPlayer(Player p) {
    float distance = dist(x, y, p.x, p.y);
    return distance < (size * 0.45 + p.getCollisionRadius());
  }
}
