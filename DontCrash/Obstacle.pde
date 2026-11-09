/**
 * Obstacle — base alien class (extends abstract WorldObject).
 *
 * Implements GameEntity via WorldObject.
 * Subclasses FastObstacle / MovingObstacle override update/display.
 */
class Obstacle extends WorldObject {
  float speed;
  float currentSpeed;
  float vx;
  float vy;
  color bodyColor;
  PImage img;

  float heading;
  float turnSpeed;
  int framesUntilTurn;
  float noiseSeedX;
  float noiseSeedY;

  Obstacle(float startX, float startY, float obstacleSize, float moveSpeed, color c) {
    this(startX, startY, obstacleSize, moveSpeed, c, null);
  }

  Obstacle(float startX, float startY, float obstacleSize, float moveSpeed, color c, PImage sprite) {
    super(startX, startY, obstacleSize);
    speed = moveSpeed;
    currentSpeed = moveSpeed;
    bodyColor = c;
    img = sprite;

    noiseSeedX = random(1000);
    noiseSeedY = random(1000);
    heading = random(TWO_PI);
    pickNewTurnBehaviour();
    applyHeadingToVelocity();
  }

  void pickNewTurnBehaviour() {
    framesUntilTurn = int(random(30, 120));
    turnSpeed = random(-0.08, 0.08);
    currentSpeed = speed * random(0.6, 1.5);
  }

  void applyHeadingToVelocity() {
    vx = cos(heading) * currentSpeed;
    vy = sin(heading) * currentSpeed;
  }

  void update() {
    framesUntilTurn--;
    if (framesUntilTurn <= 0) {
      pickNewTurnBehaviour();
    }

    float noiseTurn = map(noise(noiseSeedX, frameCount * 0.02), 0, 1, -0.05, 0.05);
    heading += turnSpeed + noiseTurn;

    if (random(1) < 0.02) {
      float toCenter = atan2(height / 2.0 - y, width / 2.0 - x);
      heading = lerpAngle(heading, toCenter, random(0.15, 0.45));
    }

    applyHeadingToVelocity();
    x += vx;
    y += vy;
    noiseSeedX += 0.01;
  }

  float lerpAngle(float from, float to, float amt) {
    float diff = atan2(sin(to - from), cos(to - from));
    return from + diff * amt;
  }

  void respawnAtEdge() {
    int side = int(random(4));
    float margin = size + 10;

    if (side == 0) {
      x = -margin;
      y = random(height);
      heading = random(-HALF_PI * 0.7, HALF_PI * 0.7);
    } else if (side == 1) {
      x = width + margin;
      y = random(height);
      heading = random(PI - HALF_PI * 0.7, PI + HALF_PI * 0.7);
    } else if (side == 2) {
      x = random(width);
      y = -margin;
      heading = random(0.3, PI - 0.3);
    } else {
      x = random(width);
      y = height + margin;
      heading = random(-PI + 0.3, -0.3);
    }

    pickNewTurnBehaviour();
    applyHeadingToVelocity();
  }

  void placeOnScreen(float px, float py) {
    x = px;
    y = py;
    heading = random(TWO_PI);
    pickNewTurnBehaviour();
    applyHeadingToVelocity();
  }

  void display() {
    pushMatrix();
    translate(x, y);

    float pulse = 1.0 + 0.07 * sin(frameCount * 0.18 + x * 0.02);
    scale(pulse);

    if (img != null) {
      imageMode(CENTER);
      image(img, 0, 0, size, size);
    } else {
      noStroke();
      fill(bodyColor);
      ellipse(0, 0, size, size * 0.75);
      fill(255);
      ellipse(-size * 0.18, -size * 0.05, size * 0.22, size * 0.28);
      ellipse(size * 0.18, -size * 0.05, size * 0.22, size * 0.28);
      fill(20);
      ellipse(-size * 0.18, -size * 0.05, size * 0.1, size * 0.14);
      ellipse(size * 0.18, -size * 0.05, size * 0.1, size * 0.14);
    }

    popMatrix();
  }

  float getCollisionRadius() {
    return size * 0.4;
  }

  /** Obstacles are removed by the main list, not via isFinished(). */
  boolean isFinished() {
    return false;
  }
}
