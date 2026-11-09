/**
 * Bullet — laser shot fired with SPACE.
 *
 * Travels in the player's facing direction from the centred ship.
 * Implements GameEntity via WorldObject.
 */
class Bullet extends WorldObject {
  float vx;
  float vy;
  boolean dead;

  Bullet(float startX, float startY, float angle, float speed) {
    super(startX, startY, 10);
    vx = cos(angle) * speed;
    vy = sin(angle) * speed;
    dead = false;
  }

  void update() {
    x += vx;
    y += vy;
  }

  void display() {
    pushMatrix();
    translate(x, y);
    float ang = atan2(vy, vx);
    rotate(ang);

    noStroke();
    // Glow
    fill(120, 220, 255, 100);
    ellipse(0, 0, 22, 10);
    // Core beam
    fill(220, 250, 255);
    rectMode(CENTER);
    rect(0, 0, 18, 4, 2);
    fill(80, 180, 255);
    rect(6, 0, 8, 3, 1);
    rectMode(CORNER);

    popMatrix();
  }

  boolean hits(Obstacle alien) {
    float distance = dist(x, y, alien.x, alien.y);
    return distance < (size * 0.5 + alien.getCollisionRadius());
  }

  boolean isFinished() {
    return dead || isOffScreen();
  }

  void markDead() {
    dead = true;
  }
}
