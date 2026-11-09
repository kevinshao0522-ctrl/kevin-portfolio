/**
 * Obstacle — base class for aliens / hazards.
 *
 * Scheme A: aliens keep moving on their own with RANDOM wandering paths
 * (not a straight line into the centre every time).
 * Phase 3 will ADD keyboard push (opposite to arrow keys) on top of this drift.
 */
class Obstacle {
  float x;
  float y;
  float size;
  float speed;       // base speed
  float currentSpeed;
  float vx;
  float vy;
  color bodyColor;

  // --- Random wander state ---
  float heading;           // current flight angle in radians
  float turnSpeed;         // how fast heading changes each frame
  int framesUntilTurn;     // countdown before picking a new turn style
  float noiseSeedX;        // unique Perlin noise offset per alien
  float noiseSeedY;

  Obstacle(float startX, float startY, float obstacleSize, float moveSpeed, color c) {
    x = startX;
    y = startY;
    size = obstacleSize;
    speed = moveSpeed;
    currentSpeed = moveSpeed;
    bodyColor = c;

    // Each alien gets its own noise seeds so paths differ
    noiseSeedX = random(1000);
    noiseSeedY = random(1000);

    // Start facing a random direction (not locked to centre)
    heading = random(TWO_PI);
    pickNewTurnBehaviour();
    applyHeadingToVelocity();
  }

  /**
   * Choose a new random turning style for a short while.
   * Sometimes almost straight, sometimes sharp curves.
   */
  void pickNewTurnBehaviour() {
    // Random duration: ~0.5s to ~2s at 60fps
    framesUntilTurn = int(random(30, 120));

    // Random turn rate (radians per frame)
    turnSpeed = random(-0.08, 0.08);

    // Occasional "dash": briefly speed up or slow down
    currentSpeed = speed * random(0.6, 1.5);
  }

  /** Convert heading + speed into vx/vy. */
  void applyHeadingToVelocity() {
    vx = cos(heading) * currentSpeed;
    vy = sin(heading) * currentSpeed;
  }

  /**
   * Every frame: wander randomly using turn + Perlin noise.
   * Soft bias toward centre only sometimes, so paths stay unpredictable
   * but aliens still tend to threaten the player over time.
   */
  void update() {
    framesUntilTurn--;
    if (framesUntilTurn <= 0) {
      pickNewTurnBehaviour();
    }

    // Smooth random wobble from Perlin noise (unique per alien)
    float noiseTurn = map(noise(noiseSeedX, frameCount * 0.02), 0, 1, -0.05, 0.05);
    heading += turnSpeed + noiseTurn;

    // ~2% chance each frame: gently nudge toward the player centre
    // (keeps tension without looking like a locked missile)
    if (random(1) < 0.02) {
      float toCenter = atan2(height / 2.0 - y, width / 2.0 - x);
      heading = lerpAngle(heading, toCenter, random(0.15, 0.45));
    }

    applyHeadingToVelocity();
    x += vx;
    y += vy;

    // Advance this alien's noise coordinate so the path keeps changing
    noiseSeedX += 0.01;

    if (isOffScreen()) {
      respawnAtEdge();
    }
  }

  /**
   * Interpolate angles correctly across the -PI / PI wrap.
   */
  float lerpAngle(float from, float to, float amt) {
    float diff = atan2(sin(to - from), cos(to - from));
    return from + diff * amt;
  }

  /** Respawn just outside a random edge, flying inward at a random angle. */
  void respawnAtEdge() {
    int side = int(random(4));
    float margin = size + 10;

    if (side == 0) {          // left → fly mostly rightward
      x = -margin;
      y = random(height);
      heading = random(-HALF_PI * 0.7, HALF_PI * 0.7);
    } else if (side == 1) {   // right → fly mostly leftward
      x = width + margin;
      y = random(height);
      heading = random(PI - HALF_PI * 0.7, PI + HALF_PI * 0.7);
    } else if (side == 2) {   // top → fly mostly downward
      x = random(width);
      y = -margin;
      heading = random(0.3, PI - 0.3);
    } else {                  // bottom → fly mostly upward
      x = random(width);
      y = height + margin;
      heading = random(-PI + 0.3, -0.3);
    }

    pickNewTurnBehaviour();
    applyHeadingToVelocity();
  }

  void display() {
    pushMatrix();
    translate(x, y);

    noStroke();
    fill(bodyColor);
    ellipse(0, 0, size, size * 0.75);

    fill(255);
    ellipse(-size * 0.18, -size * 0.05, size * 0.22, size * 0.28);
    ellipse(size * 0.18, -size * 0.05, size * 0.22, size * 0.28);
    fill(20);
    ellipse(-size * 0.18, -size * 0.05, size * 0.1, size * 0.14);
    ellipse(size * 0.18, -size * 0.05, size * 0.1, size * 0.14);

    stroke(bodyColor);
    strokeWeight(2);
    line(-size * 0.15, -size * 0.35, -size * 0.25, -size * 0.55);
    line(size * 0.15, -size * 0.35, size * 0.25, -size * 0.55);
    noStroke();
    fill(255, 80, 80);
    ellipse(-size * 0.25, -size * 0.55, 6, 6);
    ellipse(size * 0.25, -size * 0.55, 6, 6);

    popMatrix();
  }

  void moveBy(float dx, float dy) {
    x += dx;
    y += dy;
  }

  boolean isOffScreen() {
    float margin = size;
    return (x < -margin || x > width + margin ||
            y < -margin || y > height + margin);
  }

  /** Approximate collision radius used by Player.checkCollision(). */
  float getCollisionRadius() {
    return size * 0.4;
  }
}
