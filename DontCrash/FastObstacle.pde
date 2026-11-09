/**
 * FastObstacle — inherits from Obstacle.
 *
 * Different behaviour:
 * - Higher base speed
 * - Stronger pull toward the player (centre)
 * - Occasional speed burst (dash)
 *
 * Stored in ArrayList<Obstacle> via polymorphism (Phase 5/7).
 */
class FastObstacle extends Obstacle {
  int dashCooldown;

  FastObstacle(float startX, float startY, float obstacleSize, PImage sprite) {
    // Faster base speed than a normal Obstacle
    super(startX, startY, obstacleSize, random(3.5, 5.0), color(255, 150, 40), sprite);
    dashCooldown = int(random(40, 100));
  }

  /**
   * Override update(): still wander, but more aggressively chase the centre
   * and periodically dash.
   */
  @Override
  void update() {
    // Stronger, more frequent aim toward the player
    if (random(1) < 0.08) {
      float toCenter = atan2(height / 2.0 - y, width / 2.0 - x);
      heading = lerpAngle(heading, toCenter, random(0.4, 0.8));
    }

    dashCooldown--;
    if (dashCooldown <= 0) {
      currentSpeed = speed * random(1.8, 2.4); // burst
      dashCooldown = int(random(50, 120));
      framesUntilTurn = 20;
    }

    // Re-use most of the base wander logic
    framesUntilTurn--;
    if (framesUntilTurn <= 0) {
      pickNewTurnBehaviour();
      // Keep them generally faster after a normal turn pick
      currentSpeed = max(currentSpeed, speed);
    }

    float noiseTurn = map(noise(noiseSeedX, frameCount * 0.03), 0, 1, -0.04, 0.04);
    heading += turnSpeed * 1.4 + noiseTurn;
    applyHeadingToVelocity();
    x += vx;
    y += vy;
    noiseSeedX += 0.015;
  }

  @Override
  void display() {
    // Slightly sharper look: draw base image/shape, then a speed streak
    pushMatrix();
    translate(x, y);
    noStroke();
    fill(255, 200, 80, 100);
    ellipse(-vx * 2, -vy * 2, size * 0.7, size * 0.5);
    popMatrix();
    super.display();
  }
}
