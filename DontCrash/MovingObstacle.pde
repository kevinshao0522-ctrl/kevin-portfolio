/**
 * MovingObstacle.pde — Zig-zag alien subclass.
 * Adds a flipping side offset to the base velocity for a weaving path.
 */
class MovingObstacle extends Obstacle {
  float sideStep;
  int zigTimer;

  MovingObstacle(float startX, float startY, float obstacleSize, PImage sprite) {
    super(startX, startY, obstacleSize, random(1.4, 2.2), color(220, 120, 255), sprite);
    sideStep = random(2.0, 4.0);
    zigTimer = 0;
  }

  @Override
  void update() {
    float cx = width / 2.0;
    float cy = height / 2.0;
    if (x < cx) vx = vx + 0.05;
    if (x > cx) vx = vx - 0.05;
    if (y < cy) vy = vy + 0.05;
    if (y > cy) vy = vy - 0.05;

    // Alternate lateral offset to create a zig-zag
    zigTimer++;
    float extraX = 0;
    float extraY = 0;
    if ((zigTimer / 15) % 2 == 0) {
      extraX = sideStep;
    } else {
      extraX = -sideStep;
    }

    x = x + vx + extraX;
    y = y + vy + extraY;

    if ((frameCount / 10) % 2 == 0) {
      drawSize = size;
    } else {
      drawSize = size * 1.08;
    }
  }

  @Override
  void display() {
    noStroke();
    fill(220, 120, 255);
    ellipse(x, y, drawSize * 1.15, drawSize * 1.15);
    super.display();
  }
}
