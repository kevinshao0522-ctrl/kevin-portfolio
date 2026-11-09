/**
 * Player — the player's spaceship.
 *
 * Assignment rule: the ship stays FIXED at the centre of the screen.
 * Arrow keys do NOT move this object; they move obstacles / background
 * in the opposite direction (Phase 3).
 *
 * Phase 4: boolean checkCollision(Obstacle obstacle)
 */
class Player {
  float x;
  float y;
  float bodySize;
  int lives;

  Player() {
    x = width / 2.0;
    y = height / 2.0;
    bodySize = 48;
    lives = 3;
  }

  /** Approximate collision radius for circle-vs-circle tests. */
  float getCollisionRadius() {
    return bodySize * 0.45;
  }

  /**
   * Assignment-required collision method.
   * Returns true when this ship overlaps the given obstacle.
   *
   * Technique: circle collision using dist() between centres.
   * If distance < (playerRadius + obstacleRadius), they overlap.
   */
  boolean checkCollision(Obstacle obstacle) {
    float distance = dist(x, y, obstacle.x, obstacle.y);
    float minDist = getCollisionRadius() + obstacle.getCollisionRadius();
    return distance < minDist;
  }

  void display() {
    pushMatrix();
    translate(x, y);

    noStroke();
    fill(180, 210, 255);
    triangle(0, -bodySize * 0.7,
             -bodySize * 0.55, bodySize * 0.55,
             bodySize * 0.55, bodySize * 0.55);

    fill(80, 160, 255);
    ellipse(0, 0, bodySize * 0.35, bodySize * 0.35);

    fill(255, 140, 40);
    ellipse(-bodySize * 0.2, bodySize * 0.55, 8, 12);
    ellipse(bodySize * 0.2, bodySize * 0.55, 8, 12);

    popMatrix();
  }
}
