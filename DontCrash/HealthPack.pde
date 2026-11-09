/**
 * HealthPack — healing pickup (+1 life, capped at 3).
 *
 * Extends WorldObject / implements GameEntity.
 * Does NOT self-move; only shifts with arrow-key world push.
 */
class HealthPack extends WorldObject {

  HealthPack(float startX, float startY) {
    super(startX, startY, 36);
  }

  void update() {
    // Stationary: intentional no-op (still participates in GameEntity polymorphism)
  }

  void display() {
    pushMatrix();
    translate(x, y);

    float pulse = 1.0 + 0.08 * sin(frameCount * 0.15);
    scale(pulse);

    noStroke();
    fill(80, 255, 140, 70);
    ellipse(0, 0, size * 1.6, size * 1.6);

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
}
