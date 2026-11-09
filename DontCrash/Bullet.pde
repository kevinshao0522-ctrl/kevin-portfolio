/**
 * Bullet — circular laser pulse with fixed vx/vy (no cos/sin/rotate).
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
    // Outer glow ring
    fill(40, 160, 255);
    ellipse(x, y, size * 1.6, size * 1.6);
    // Mid laser disc
    fill(80, 210, 255);
    ellipse(x, y, size * 1.15, size * 1.15);
    // Bright core
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
