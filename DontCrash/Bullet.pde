/**
 * Bullet.pde — Circular laser shot fired by the player.
 * Travels with fixed vx/vy along the ship's facing direction.
 */
class Bullet extends WorldObject {
  float vx;
  float vy;
  boolean dead;

  Bullet(float startX, float startY, float velX, float velY) {
    super(startX, startY, 16);
    vx = velX;
    vy = velY;
    dead = false;
  }

  void update() {
    x = x + vx;
    y = y + vy;
  }

  void display() {
    noStroke();
    fill(40, 160, 255);
    ellipse(x, y, size * 1.6, size * 1.6);
    fill(80, 210, 255);
    ellipse(x, y, size * 1.15, size * 1.15);
    fill(220, 250, 255);
    ellipse(x, y, size * 0.55, size * 0.55);
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
