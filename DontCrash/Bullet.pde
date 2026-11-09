/**
 * Bullet — laser with fixed vx/vy (no cos/sin/rotate).
 */
class Bullet extends WorldObject {
  float vx;
  float vy;
  boolean dead;

  Bullet(float startX, float startY, float velX, float velY) {
    super(startX, startY, 10);
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
    fill(120, 220, 255);
    ellipse(x, y, 18, 8);
    fill(220, 250, 255);
    rect(x - 9, y - 2, 18, 4);
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
