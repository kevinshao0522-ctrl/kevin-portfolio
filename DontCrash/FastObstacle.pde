/**
 * FastObstacle.pde — Fast alien subclass with stronger centre pull and dashes.
 * Extends Obstacle; overrides update/display for aggression and a speed streak.
 */
class FastObstacle extends Obstacle {
  int dashCooldown;

  FastObstacle(float startX, float startY, float obstacleSize, PImage sprite) {
    super(startX, startY, obstacleSize, random(3.5, 5.0), color(255, 150, 40), sprite);
    dashCooldown = int(random(40, 100));
  }

  @Override
  void update() {
    if (random(1) < 0.08) {
      float cx = width / 2.0;
      float cy = height / 2.0;
      if (x < cx) vx = speed;
      if (x > cx) vx = -speed;
      if (y < cy) vy = speed;
      if (y > cy) vy = -speed;
    }

    dashCooldown--;
    if (dashCooldown <= 0) {
      // Short burst: double current velocity
      vx = vx * 2;
      vy = vy * 2;
      dashCooldown = int(random(50, 120));
      framesUntilTurn = 20;
    }

    framesUntilTurn--;
    if (framesUntilTurn <= 0) {
      pickNewVelocity();
      if (vx < 0 && vx > -speed) vx = -speed;
      if (vx > 0 && vx < speed) vx = speed;
      if (vy < 0 && vy > -speed) vy = -speed;
      if (vy > 0 && vy < speed) vy = speed;
    }

    x = x + vx;
    y = y + vy;

    if ((frameCount / 8) % 2 == 0) {
      drawSize = size;
    } else {
      drawSize = size * 1.1;
    }
  }

  @Override
  void display() {
    noStroke();
    fill(255, 200, 80);
    ellipse(x - vx * 2, y - vy * 2, drawSize * 0.7, drawSize * 0.5);
    super.display();
  }
}
