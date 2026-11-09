/**
 * MovingObstacle — inherits from Obstacle.
 *
 * Different behaviour:
 * - Side-to-side zig-zag while advancing
 * - Slower forward speed but hard to predict laterally
 */
class MovingObstacle extends Obstacle {
  float zigPhase;
  float zigAmplitude;

  MovingObstacle(float startX, float startY, float obstacleSize, PImage sprite) {
    super(startX, startY, obstacleSize, random(1.4, 2.2), color(220, 120, 255), sprite);
    zigPhase = random(TWO_PI);
    zigAmplitude = random(2.0, 4.0);
  }

  @Override
  void update() {
    // Soft pull toward centre for forward progress
    float toCenter = atan2(height / 2.0 - y, width / 2.0 - x);
    heading = lerpAngle(heading, toCenter, 0.03);

    // Perpendicular zig-zag offset
    zigPhase += 0.12;
    float sideX = cos(toCenter + HALF_PI) * sin(zigPhase) * zigAmplitude;
    float sideY = sin(toCenter + HALF_PI) * sin(zigPhase) * zigAmplitude;

    applyHeadingToVelocity();
    x += vx + sideX;
    y += vy + sideY;
  }

  @Override
  void display() {
    // Purple ring to visually distinguish this subclass
    pushMatrix();
    translate(x, y);
    noFill();
    stroke(220, 120, 255, 180);
    strokeWeight(2);
    ellipse(0, 0, size * 1.15, size * 1.15);
    noStroke();
    popMatrix();
    super.display();
  }
}
