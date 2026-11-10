/**
 * Obstacle — base alien class.
 * Moves with vx/vy only (no cos/sin/atan2/noise).
 */
class Obstacle extends WorldObject {
  float speed;
  float vx;
  float vy;
  color bodyColor;
  PImage img;

  int framesUntilTurn;
  float drawSize;   // pulse by changing this, not scale()
  private boolean dead;     // mark first; main loop removes later

  Obstacle(float startX, float startY, float obstacleSize, float moveSpeed, color c) {
    this(startX, startY, obstacleSize, moveSpeed, c, null);
  }

  Obstacle(float startX, float startY, float obstacleSize, float moveSpeed, color c, PImage sprite) {
    super(startX, startY, obstacleSize);
    speed = moveSpeed;
    bodyColor = c;
    img = sprite;
    drawSize = obstacleSize;
    dead = false;
    pickNewVelocity();
  }

  void markDead() {
    dead = true;
  }

  boolean isDead() {
    return dead;
  }

  /** Pick a random velocity using only random() on vx/vy. */
  void pickNewVelocity() {
    framesUntilTurn = int(random(30, 120));
    // Four-ish free directions via random components
    vx = random(-speed, speed);
    vy = random(-speed, speed);
    // Avoid almost-zero motion
    if (vx > -0.3 && vx < 0.3) {
      if (random(1) < 0.5) vx = speed;
      else vx = -speed;
    }
    if (vy > -0.3 && vy < 0.3) {
      if (random(1) < 0.5) vy = speed * 0.5;
      else vy = -speed * 0.5;
    }
  }

  /** Softly pull toward centre using comparisons (no atan2). */
  void nudgeTowardCenter() {
    float cx = width / 2.0;
    float cy = height / 2.0;
    if (x < cx) vx = vx + 0.15;
    if (x > cx) vx = vx - 0.15;
    if (y < cy) vy = vy + 0.15;
    if (y > cy) vy = vy - 0.15;
  }

  void update() {
    framesUntilTurn--;
    if (framesUntilTurn <= 0) {
      pickNewVelocity();
    }

    if (random(1) < 0.02) {
      nudgeTowardCenter();
    }

    x = x + vx;
    y = y + vy;

    // Pulse size with a simple frame toggle (no sin/scale)
    if ((frameCount / 10) % 2 == 0) {
      drawSize = size;
    } else {
      drawSize = size * 1.08;
    }
  }

  void respawnAtEdge() {
    int side = int(random(4));
    float margin = size + 10;

    if (side == 0) {
      x = -margin;
      y = random(height);
      vx = random(speed * 0.5, speed * 1.2);
      vy = random(-speed, speed);
    } else if (side == 1) {
      x = width + margin;
      y = random(height);
      vx = random(-speed * 1.2, -speed * 0.5);
      vy = random(-speed, speed);
    } else if (side == 2) {
      x = random(width);
      y = -margin;
      vx = random(-speed, speed);
      vy = random(speed * 0.5, speed * 1.2);
    } else {
      x = random(width);
      y = height + margin;
      vx = random(-speed, speed);
      vy = random(-speed * 1.2, -speed * 0.5);
    }

    framesUntilTurn = int(random(30, 120));
  }

  void placeOnScreen(float px, float py) {
    x = px;
    y = py;
    pickNewVelocity();
  }

  void display() {
    if (img != null) {
      // Default imageMode CORNER: convert centre to top-left
      image(img, x - drawSize / 2, y - drawSize / 2, drawSize, drawSize);
    } else {
      noStroke();
      fill(bodyColor);
      ellipse(x, y, drawSize, drawSize * 0.75);
      fill(255);
      ellipse(x - drawSize * 0.18, y - drawSize * 0.05, drawSize * 0.22, drawSize * 0.28);
      ellipse(x + drawSize * 0.18, y - drawSize * 0.05, drawSize * 0.22, drawSize * 0.28);
      fill(20);
      ellipse(x - drawSize * 0.18, y - drawSize * 0.05, drawSize * 0.1, drawSize * 0.14);
      ellipse(x + drawSize * 0.18, y - drawSize * 0.05, drawSize * 0.1, drawSize * 0.14);
    }
  }

  float getCollisionRadius() {
    // Match the smaller drawn body (tight hitbox)
    return size * 0.35;
  }

  boolean isFinished() {
    return dead;
  }
}
